//
//  AppDependencies.swift
//  SupabaseSwiftUI
//
//  Composition root: holds the SupabaseClient singleton and wires up repositories.
//

import Foundation
import Supabase

/// Shared Supabase client. supabase-swift persists the session to the Keychain
/// automatically, so on relaunch `auth.currentSession` is restored for us.
let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.anonKey,
    options: SupabaseClientOptions(
        // Opt in to the upcoming default: always emit the locally stored session
        // as the initial session, regardless of validity/expiration. Consumers of
        // the initial session must check `session.isExpired` themselves.
        auth: SupabaseClientOptions.AuthOptions(
            emitLocalSessionAsInitialSession: true
        )
    )
)

@MainActor
final class AppDependencies {
    static let shared = AppDependencies()

    let authRepository: AuthRepository
    let notesRepository: NotesRepository
    let sessionManager: SessionManager

    private init() {
        let auth = AuthRepositoryImpl(client: supabase)
        self.authRepository = auth
        self.notesRepository = NotesRepositoryImpl(client: supabase)
        self.sessionManager = SessionManager(authRepository: auth)
    }
}
