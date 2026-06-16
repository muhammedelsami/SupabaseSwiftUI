//
//  ContentView.swift
//  SupabaseSwiftUI
//
//  Root view: shows the splash, then routes to auth or the main app.
//

import SwiftUI

struct ContentView: View {
    @Environment(SessionManager.self) private var sessionManager
    @State private var showSplash = true

    var body: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()

            if showSplash {
                SplashView { showSplash = false }
                    .transition(.opacity)
            } else if sessionManager.isLoggedIn {
                MainTabView()
                    .transition(.opacity)
            } else {
                AuthView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showSplash)
        .animation(.easeInOut(duration: 0.35), value: sessionManager.isLoggedIn)
    }
}

#Preview {
    ContentView()
        .environment(AppDependencies.shared.sessionManager)
}
