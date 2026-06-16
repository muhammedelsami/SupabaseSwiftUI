//
//  SplashView.swift
//  SupabaseSwiftUI
//

import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void

    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.backgroundDark, AppColors.indigoNight, AppColors.backgroundDark],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(AppColors.primaryLight)
                    .scaleEffect(animate ? 1.0 : 0.6)
                    .opacity(animate ? 1.0 : 0.0)

                Text("Premium Notes")
                    .font(AppFonts.displayMedium)
                    .foregroundStyle(AppColors.textPrimary)
                    .opacity(animate ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                animate = true
            }
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                onFinish()
            }
        }
    }
}

#Preview {
    SplashView {}
}
