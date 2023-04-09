import SwiftUI
import LocalAuthentication

struct GradientText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing))
            .mask(content)
    }
}

struct MainMenuView: View {
    @State private var showWalletDetails = false
    @State private var boothsScanned = 0
    @State private var isShowingScannerView = false
    @State private var scannedText: String = ""
    let walletAddress: String
    let publicKey: String
    @State private var privateKey = ""
    @State private var disableFaceID = false // Add a state variable to track whether to disable Face ID authentication

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                Text("ETH Denver Conference")
                    .font(.largeTitle)
                    .modifier(GradientText())
                Spacer()
                Button(action: {
                    if showWalletDetails {
                        disableFaceID = true // Set disableFaceID to true when "Hide Wallet Details" is clicked
                        showWalletDetails = false // Set showWalletDetails to false when "Hide Wallet Details" is clicked
                    } else {
                        disableFaceID = false // Set disableFaceID to false when "Retrieve Wallet Details" is clicked
                        authenticateAndShowDetails()
                    }
                }) {
                    Text(showWalletDetails ? "Hide My Wallet" : "Retrieve My Wallet") // Update the button text based on the state of showWalletDetails
                        .foregroundColor(.white)
                        .padding()
                        .modifier(GradientButton())
                        .cornerRadius(10)
                }

                if showWalletDetails {
                    VStack (alignment: .leading, spacing: 10) {
                        Text("Wallet Address: \(walletAddress)")
                        Text("Public Key: \(publicKey)")
                        Text("Private Key: \(privateKey)")
                    }
                }
                ProgressBar(value: CGFloat(boothsScanned), maximumValue: CGFloat(sampleBooths.count))
                    .frame(height: 10)
                Text("Booths Scanned: \(boothsScanned)/\(sampleBooths.count)")
                HStack(spacing: 30) {
                    Button(action: {
                        isShowingScannerView = true
                    }) {
                        Text("Scan QR Code")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: MintNFTView(walletAddress: walletAddress, publicKey: publicKey, privateKey: privateKey)) {
                        Text("Mint NFT")
                            .padding()
                            .background(boothsScanned == sampleBooths.count ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(boothsScanned != sampleBooths.count)
                }
                Spacer()
            }
            .padding()
            .sheet(isPresented: $isShowingScannerView) {
                QRCodeScannerView { code in
                    if let boothCode = code {
                        boothsScanned += 1
                        print("Scanned booth code: \(boothCode)")
                    }
                    isShowingScannerView = false
                }
            }

        }
    }

    func authenticateAndShowDetails() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access your wallet details") { success, _ in
                DispatchQueue.main.async {
                    if success {
                        showWalletDetails = true
                    }
                }
            }
        }
    }

    func retrievePrivateKey() {
        let keychain = KeychainWrapper()
        privateKey = keychain.get("privateKey") ?? ""
    }
}


struct ProgressBar: View {
    var value: CGFloat
    var maximumValue: CGFloat
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(Color.gray.opacity(0.5))
                Capsule()
                    .frame(width: min(CGFloat(value/maximumValue)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color.green)
            }
        }
    }
}

