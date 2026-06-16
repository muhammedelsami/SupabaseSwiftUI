//
//  ForgotPasswordViewModel.swift
//  SupabaseSwiftUI
//

import Foundation
import Observation

@MainActor
@Observable
final class ForgotPasswordViewModel {
    var email = ""
    var isLoading = false
    var error: String?
    var didSend = false

    private let authRepository: AuthRepository

    init() {
        self.authRepository = AppDependencies.shared.authRepository
    }

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func sendResetLink() async {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else {
            error = "Please enter your email."
            return
        }
        isLoading = true
        error = nil
        defer { isLoading = false }

        switch await authRepository.sendResetPasswordLink(email: trimmed) {
        case .success:
            didSend = true
        case .error(let message):
            error = message
        case .loading:
            break
        }
    }
}
