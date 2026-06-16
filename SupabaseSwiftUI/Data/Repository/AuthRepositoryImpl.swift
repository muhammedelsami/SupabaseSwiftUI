//
//  AuthRepositoryImpl.swift
//  SupabaseSwiftUI
//

import Foundation
import Supabase

final class AuthRepositoryImpl: AuthRepository {
    private let client: SupabaseClient
    private let notesRepository: NotesRepository

    init(client: SupabaseClient) {
        self.client = client
        self.notesRepository = NotesRepositoryImpl(client: client)
    }

    func register(name: String, email: String, password: String) async -> Resource<Void> {
        do {
            try await client.auth.signUp(
                email: email,
                password: password,
                data: ["name": .string(name)]
            )
            return .success(())
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func login(email: String, password: String) async -> Resource<Void> {
        do {
            try await client.auth.signIn(email: email, password: password)
            return .success(())
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func sendResetPasswordLink(email: String) async -> Resource<Void> {
        do {
            try await client.auth.resetPasswordForEmail(
                email,
                redirectTo: SupabaseConfig.resetPasswordRedirect
            )
            return .success(())
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func logout() async -> Resource<Void> {
        do {
            try await client.auth.signOut()
            return .success(())
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func deleteAccount() async -> Resource<Void> {
        guard let session = currentSession() else {
            return .error("No active session.")
        }
        // 1. Remove all of the user's notes and their stored images first.
        if case let .error(message) = await notesRepository.deleteAllUserData(userId: session.userId) {
            return .error(message)
        }
        // 2. Ask the Edge Function to delete the auth user, then sign out locally.
        do {
            try await client.functions.invoke("delete-user-account")
            try? await client.auth.signOut()
            return .success(())
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func getProfile() async -> Resource<UserProfile> {
        do {
            let user = try await client.auth.user()
            let name = user.userMetadata["name"]?.stringValue
            let profile = UserProfile(
                id: user.id.uuidString,
                name: name,
                email: user.email ?? ""
            )
            return .success(profile)
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func updateProfile(name: String) async -> Resource<Void> {
        do {
            try await client.auth.update(user: UserAttributes(data: ["name": .string(name)]))
            return .success(())
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func currentSession() -> SessionInfo? {
        guard let session = client.auth.currentSession else { return nil }
        return SessionInfo(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            userId: session.user.id.uuidString,
            email: session.user.email ?? ""
        )
    }
}
