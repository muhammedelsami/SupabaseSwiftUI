//
//  SupabaseSwiftUIApp.swift
//  SupabaseSwiftUI
//
//  Created by Muhammed Elşami on 16.06.2026.
//

import SwiftUI
import Supabase

@main
struct SupabaseSwiftUIApp: App {
    @State private var sessionManager = AppDependencies.shared.sessionManager

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessionManager)
                .preferredColorScheme(.dark)
                .tint(AppColors.primaryMain)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    /// Lets supabase-swift consume auth deep links (e.g. password-reset callback).
    private func handleDeepLink(_ url: URL) {
        Task {
            do {
                try await supabase.auth.session(from: url)
                sessionManager.refresh()
            } catch {
                // Not an auth URL we can handle; ignore.
            }
        }
    }
}
