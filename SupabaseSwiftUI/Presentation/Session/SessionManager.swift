//
//  SessionManager.swift
//  SupabaseSwiftUI
//

import Foundation
import Observation

@MainActor
@Observable
final class SessionManager {
    var currentSession: SessionInfo?

    var isLoggedIn: Bool { currentSession != nil }

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
        // On launch, restore any session supabase-swift kept in the Keychain.
        self.currentSession = authRepository.currentSession()
    }

    /// Re-reads the current session (after login / logout / deep link).
    func refresh() {
        currentSession = authRepository.currentSession()
    }

    func setLoggedOut() {
        currentSession = nil
    }
}
