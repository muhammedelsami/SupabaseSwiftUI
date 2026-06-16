//
//  AuthRepository.swift
//  SupabaseSwiftUI
//

import Foundation

protocol AuthRepository {
    func register(name: String, email: String, password: String) async -> Resource<Void>
    func login(email: String, password: String) async -> Resource<Void>
    func sendResetPasswordLink(email: String) async -> Resource<Void>
    func logout() async -> Resource<Void>
    func deleteAccount() async -> Resource<Void>
    func getProfile() async -> Resource<UserProfile>
    func updateProfile(name: String) async -> Resource<Void>
    func currentSession() -> SessionInfo?
}
