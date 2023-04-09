import SwiftUI
import LocalAuthentication
import web3swift
import Web3Core


struct MintNFTView: View {
    var walletAddress: String
    var publicKey: String
    var privateKey: String
    @State private var isAuthenticating = false
    
    var body: some View {
        VStack {
            Text("Congratulations")
                .font(.largeTitle)
                .modifier(GradientText())
            
            Button(action: {
                self.isAuthenticating = true
                authenticateAndMint()
            }) {
                Text("Authorize with Face ID and receive your NFT")
            }
        }
    }
    
    private func authenticateAndMint() {
        let context = LAContext()
        let reason = "Authenticate to unlock your wallet and mint an NFT."

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    DispatchQueue.main.async {
                        unlockWalletAndMintNFT(walletAddress: walletAddress, publicKey: publicKey, ipfsAddress: "", ipfsImage: "") { result in
                            switch result {
                            case .success(let txHash):
                                print("Transaction hash: \(txHash)")
                            case .failure(let error):
                                print("Error: \(error)")
                            }
                        }
                    }
                } else {
                    print("Authentication failed: \(String(describing: error))")
                }
            }
        } else {
            print("Face ID not available.")
        }
    }
    
    func unlockWalletAndMintNFT(walletAddress: String, publicKey: String, ipfsAddress: String, ipfsImage: String, completion: @escaping (Result<String, Error>) -> Void) {
        // TODO: Implement unlockWalletAndMintNFT function using web3swift library and your smart contract
        
    }
}


