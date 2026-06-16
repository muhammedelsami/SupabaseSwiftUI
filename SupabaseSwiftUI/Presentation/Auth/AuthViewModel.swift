//
//  AuthViewModel.swift
//  SupabaseSwiftUI
//

import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
    // Form state
    var name = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    var isLoginMode = true

    // UI state
    var isLoading = false
    var error: String?
    var loginSuccess = false

    private let authRepository: AuthRepository
    private let sessionManager: SessionManager

    init() {
        self.authRepository = AppDependencies.shared.authRepository
        self.sessionManager = AppDependencies.shared.sessionManager
    }

    init(authRepository: AuthRepository, sessionManager: SessionManager) {
        self.authRepository = authRepository
        self.sessionManager = sessionManager
    }

    func toggleMode() {
        isLoginMode.toggle()
        error = nil
    }

    func login() async {
        guard validateLogin() else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }

        switch await authRepository.login(email: trimmedEmail, password: password) {
        case .success:
            sessionManager.refresh()
            loginSuccess = true
        case .error(let message):
            error = message
        case .loading:
            break
        }
    }

    func register() async {
        guard validateRegister() else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }

        switch await authRepository.register(name: name.trimmingCharacters(in: .whitespaces), email: trimmedEmail, password: password) {
        case .success:
            // Auto sign-in after registration so the user lands straight in the app.
            switch await authRepository.login(email: trimmedEmail, password: password) {
            case .success:
                sessionManager.refresh()
                loginSuccess = true
            case .error(let message):
                error = message
            case .loading:
                break
            }
        case .error(let message):
            error = message
        case .loading:
            break
        }
    }

    // MARK: - Validation

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func validateLogin() -> Bool {
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            error = "Please enter your email and password."
            return false
        }
        return true
    }

    private func validateRegister() -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            error = "Please enter your name."
            return false
        }
        guard !trimmedEmail.isEmpty else {
            error = "Please enter your email."
            return false
        }
        guard password.count >= 6 else {
            error = "Password must be at least 6 characters."
            return false
        }
        guard password == confirmPassword else {
            error = "Passwords do not match."
            return false
        }
        return true
    }
}
