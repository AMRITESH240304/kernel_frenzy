//
//  LoginView.swift
//  kernel_frenzy
//
//  Created by admin49 on 08/02/25.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}


struct LoginView: View {
    
    @StateObject private var viewModel = AuthService()
    @State private var isLoggedIn = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
            ZStack {
                BackgroundView()
                VStack {
                    Spacer()
                    
                    Text("Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 15) {
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

                    Button(action: loginUser) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
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
                    .padding()
                    
                    Spacer()
                    
                    NavigationLink(destination: RegisterView()) {
                        Text("Don't have an account? Register")
                            .foregroundColor(.white)
                            .underline()
                    }
                }
                .padding()
                .navigationDestination(isPresented: $isLoggedIn) {
                    TabsView()
                }
            }
        }
    
    func loginUser() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await viewModel.login()
                DispatchQueue.main.async {
                    isLoggedIn = true
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
    LoginView()
}
