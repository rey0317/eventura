import SwiftUI
import AVFoundation
import CoreLocation

struct QRCodeScannerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ScannerViewController
    let onScannedCode: (String?) -> Void
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let scannerViewController = ScannerViewController()
        scannerViewController.delegate = context.coordinator
        context.coordinator.scannerViewController = scannerViewController
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onScannedCode: onScannedCode)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let onScannedCode: (String?) -> Void
        var isScanning = true
        @ObservedObject var locationManager = LocationManager()
        weak var scannerViewController: ScannerViewController?
        
        init(onScannedCode: @escaping (String?) -> Void) {
            self.onScannedCode = onScannedCode
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard isScanning else { return }
            
            if let qrCodeObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let scannedText = qrCodeObject.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines) {
                
                print("Scanned text: \(scannedText)")
                
                if var booth = sampleBooths.first(where: { $0.id == scannedText && !$0.isScanned }),
                   let userLocation = locationManager.currentLocation {
                    
                    let boothLocation = CLLocation(latitude: booth.location.latitude, longitude: booth.location.longitude)
                    let distanceInMeters = userLocation.distance(from: boothLocation)
                    let distanceInMiles = distanceInMeters / 1609.34
                    
                    print("Booth found: \(booth.title)")
                    
                    if distanceInMiles <= 1 {
                        if var boothIndex = sampleBooths.firstIndex(where: { $0.id == booth.id }) {
                            // Update the `isScanned` property of the booth in `sampleBooths`
                            sampleBooths[boothIndex].isScanned = true
                        }
                        let message = "You have successfully scanned booth \(booth.title)."
                        let alertController = UIAlertController(title: "Success!", message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.onScannedCode(scannedText)
                            booth.isScanned = true
                            self.isScanning = false
                            self.scannerViewController?.dismiss(animated: true, completion: nil)
                        }))
                        scannerViewController?.present(alertController, animated: true, completion: nil)
                    } else {
                        let message = "Booth \(booth.title) is more than 1 mile away. Please go closer to the booth."
                        let alertController = UIAlertController(title: "Too far", message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.scannerViewController?.dismiss(animated: true, completion: nil)
                        }))
                        scannerViewController?.present(alertController, animated: true, completion: nil)
                    }
                } else if let booth = sampleBooths.first(where: { $0.id == scannedText && $0.isScanned }) {
                    let message = "You have already scanned booth \(booth.title)."
                    let alertController = UIAlertController(title: "Duplicate scan", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.scannerViewController?.dismiss(animated: true, completion: nil)
                    }))
                    scannerViewController?.present(alertController, animated: true, completion: nil)
                } else {
                    let message = "Booth not found."
                    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.scannerViewController?.dismiss(animated: true, completion: nil)
                    }))
                    scannerViewController?.present(alertController, animated: true, completion: nil)
                }
            }
        }


    }
}

    
    final class ScannerViewController: UIViewController {
        var delegate: AVCaptureMetadataOutputObjectsDelegate?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
            let captureSession = AVCaptureSession()
            
            do {
                let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(deviceInput)
            } catch {
                print("Failed to create input: \(error.localizedDescription)")
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            
            if metadataOutput.availableMetadataObjectTypes.contains(AVMetadataObject.ObjectType.qr) {
                metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            // Call startRunning on a background thread
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        }
        
        
        func showAlert(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated:
                        true, completion: nil)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        override var prefersStatusBarHidden: Bool {
            return true
        }
        
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .portrait
        }
    }
    
