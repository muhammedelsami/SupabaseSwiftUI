//
//  ForgotPasswordView.swift
//  SupabaseSwiftUI
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ForgotPasswordViewModel()

    var body: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Reset Password")
                        .font(AppFonts.titleLarge)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("We'll email you a link to reset your password.")
                        .font(AppFonts.bodyMedium)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                if viewModel.didSend {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(AppColors.secondaryMain)
                        Text("Reset link sent. Check your inbox.")
                            .font(AppFonts.bodyMedium)
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ThemedField(
                        title: "Email",
                        systemImage: "envelope",
                        text: $viewModel.email,
                        keyboard: .emailAddress,
                        textContentType: .emailAddress
                    )

                    if let error = viewModel.error {
                        Text(error)
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.errorMain)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if viewModel.isLoading {
                        ProgressView().tint(AppColors.primaryLight)
                    } else {
                        Button("Send Reset Link") {
                            Task { await viewModel.sendResetLink() }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }

                Spacer()
            }
            .padding(24)
        }
    }
}

#Preview {
    ForgotPasswordView()
}
