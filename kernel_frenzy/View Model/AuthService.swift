//
//  RegisterViewModel.swift
//  kernel_frenzy
//
//  Created by admin49 on 06/02/25.
//

import Appwrite
import Foundation

// Singleton Client instance
class AppwriteService {
    static let shared = AppwriteService()
    
    let client: Client
    let account: Account

    private init() {
        self.client = Client()
            .setEndpoint("https://cloud.appwrite.io/v1")
            .setProject("67a78ee80034a4cecd30")

        self.account = Account(client)
    }
}

@MainActor
class AuthService: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""

    private let appwrite = AppwriteService.shared

    func register() async throws {
        do {
            let user = try await appwrite.account.create(
                userId: UUID().uuidString,
                email: email,
                password: password,
                name: name
            )
            let post = Post()
            await post.saveUserInfo(UUID(uuidString: user.id)!, name, email)
        } catch {
            print("Registration failed: \(error.localizedDescription)")
            throw error
        }
    }

    func login() async throws {
        do {
            _ = try await appwrite.account.createEmailPasswordSession(
                email: email,
                password: password
            )
        } catch {
            print("Login failed: \(error.localizedDescription)")
            throw error
        }
    }
}
