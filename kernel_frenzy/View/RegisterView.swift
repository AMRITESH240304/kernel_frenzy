import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = AuthService()
    @State private var isRegistered = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack {
                    Spacer()
                    
                    Text("Register")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 15) {
                        TextField("Full Name", text: $viewModel.name)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                        
                        TextField("Email", text: $viewModel.email)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()

                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                    }
                    .padding()
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.bottom, 5)
                    }

                    Button(action: registerUser) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Register")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLoading ? Color.gray : Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .disabled(isLoading)
                    
                    Spacer()
                    
                    NavigationLink(destination: LoginView()) {
                        Text("Already a member? Login")
                            .foregroundColor(.white)
                            .underline()
                    }
                }
                .padding()
                .navigationDestination(isPresented: $isRegistered) {
                    LoginView()
                }
            }
        }
    }
    
    private func registerUser() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await viewModel.register()
                DispatchQueue.main.async {
                    isRegistered = true
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
            }
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
}

#Preview {
    RegisterView()
}
