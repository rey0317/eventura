import SwiftUI

struct GradientText2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing))
            .mask(content)
    }
}

struct GradientButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                                       startPoint: .leading,
                                       endPoint: .trailing))
            .cornerRadius(10)
    }
}

struct ContentView: View {
    @State private var walletAddress = ""
    @State private var publicKey = ""
    @State private var isCredentialsValid = false
    @State private var isNavigatingToFaceIDView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Eventura")
                    .font(.largeTitle)
                    .modifier(GradientText2())
                    .padding(.top)

                VStack(spacing: 15) {
                    TextField("Wallet Address", text: $walletAddress)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .onChange(of: walletAddress, perform: { value in
                            validateCredentials()
                        })

                    TextField("Public Key", text: $publicKey)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .onChange(of: publicKey, perform: { value in
                            validateCredentials()
                        })
                }

                Button(action: {
                    isNavigatingToFaceIDView = true
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .padding()
                        .cornerRadius(10)
                        .modifier(GradientButton())
                }
                .disabled(!isCredentialsValid)
                .fullScreenCover(isPresented: $isNavigatingToFaceIDView, content: {
                    FaceIDView(walletAddress: walletAddress, publicKey: publicKey)
                })

                Spacer()
            }
            .padding()
        }
    }

    func validateCredentials() {
        isCredentialsValid = !walletAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !publicKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

