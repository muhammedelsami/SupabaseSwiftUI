//
//  MainTabView.swift
//  SupabaseSwiftUI
//

import SwiftUI

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.surfaceDark)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "doc.text")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .tint(AppColors.primaryLight)
    }
}

#Preview {
    MainTabView()
        .environment(AppDependencies.shared.sessionManager)
}
