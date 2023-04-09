import SwiftUI
import LocalAuthentication

struct FaceIDView: View {
    @State private var isUnlocked = false
    @State private var privateKey = ""
    let walletAddress: String
    let publicKey: String

    var body: some View {
        VStack(spacing: 15) {
            if isUnlocked {
                MainMenuView(walletAddress: walletAddress, publicKey: publicKey)
            } else {
//                Text("Let's save your wallet credentials")
//                    .font(.subheadline)
//                    .modifier(GradientText2())
//                    .padding(.top)
//
                Text("Eventura")
                    .font(.largeTitle)
                    .modifier(GradientText2())
                    .padding(.top)
                
                TextField("Enter private key", text: $privateKey)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(width: 300)
            

                Button(action: authenticateAndSavePrivateKey) {
                    Text("Authenticate with Face ID")
                        .foregroundColor(.white)
                        .padding()
                        .modifier(GradientButton())
                        .cornerRadius(10)
                }
            }
        }
        .onAppear(perform: saveKeysToKeychain)
    }

    func saveKeysToKeychain() {
        let keychain = KeychainWrapper()
        keychain.save(walletAddress, forKey: "walletAddress")
        keychain.save(publicKey, forKey: "publicKey")
    }

    func authenticateAndSavePrivateKey() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access your wallet details") { success, _ in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                        let keychain = KeychainWrapper()
                        keychain.save(privateKey, forKey: "privateKey")
                    }
                }
            }
        }
    }
}


