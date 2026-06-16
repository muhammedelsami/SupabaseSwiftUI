//
//  ProfileViewModel.swift
//  SupabaseSwiftUI
//

import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    var profile: UserProfile?
    var nameInput = ""

    var isLoading = true
    var isSaving = false
    var isEditing = false
    var successMessage: String?
    var error: String?

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

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }

        switch await authRepository.getProfile() {
        case .success(let result):
            profile = result
            nameInput = result.name ?? ""
        case .error(let message):
            error = message
        case .loading:
            break
        }
    }

    func toggleEdit() {
        if isEditing {
            // Cancelling: reset the field back to the stored name.
            nameInput = profile?.name ?? ""
        }
        isEditing.toggle()
    }

    func saveProfile() async {
        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            error = "Name cannot be empty."
            return
        }
        isSaving = true
        defer { isSaving = false }

        switch await authRepository.updateProfile(name: trimmed) {
        case .success:
            isEditing = false
            successMessage = "Profile updated."
            await loadProfile()
        case .error(let message):
            error = message
        case .loading:
            break
        }
    }

    func logout() async {
        isSaving = true
        defer { isSaving = false }

        switch await authRepository.logout() {
        case .success:
            sessionManager.setLoggedOut()
        case .error(let message):
            error = message
        case .loading:
            break
        }
    }

    func deleteAccount() async {
        isSaving = true
        defer { isSaving = false }

        switch await authRepository.deleteAccount() {
        case .success:
            sessionManager.setLoggedOut()
        case .error(let message):
            error = message
        case .loading:
            break
        }
    }
}
