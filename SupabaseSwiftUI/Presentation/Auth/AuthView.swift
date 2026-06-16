//
//  AuthView.swift
//  SupabaseSwiftUI
//

import SwiftUI

struct AuthView: View {
    @State private var viewModel = AuthViewModel()
    @State private var showForgotPassword = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.backgroundDark, AppColors.indigoNight, AppColors.backgroundDark],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    header
                    card
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.primaryLight)

            Text("Premium Notes")
                .font(AppFonts.displayMedium)
                .foregroundStyle(AppColors.textPrimary)

            Text(viewModel.isLoginMode ? "Welcome back" : "Create your account")
                .font(AppFonts.bodyMedium)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.top, 20)
    }

    private var card: some View {
        VStack(spacing: 16) {
            if !viewModel.isLoginMode {
                ThemedField(
                    title: "Name",
                    systemImage: "person",
                    text: $viewModel.name,
                    textContentType: .name
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            ThemedField(
                title: "Email",
                systemImage: "envelope",
                text: $viewModel.email,
                keyboard: .emailAddress,
                textContentType: .emailAddress
            )

            ThemedField(
                title: "Password",
                systemImage: "lock",
                text: $viewModel.password,
                isSecure: true,
                textContentType: .password
            )

            if !viewModel.isLoginMode {
                ThemedField(
                    title: "Confirm Password",
                    systemImage: "lock.rotation",
                    text: $viewModel.confirmPassword,
                    isSecure: true
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            if let error = viewModel.error {
                Text(error)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.errorMain)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if viewModel.isLoading {
                ProgressView()
                    .tint(AppColors.primaryLight)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else {
                Button(viewModel.isLoginMode ? "Sign In" : "Sign Up") {
                    Task {
                        if viewModel.isLoginMode {
                            await viewModel.login()
                        } else {
                            await viewModel.register()
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }

            if viewModel.isLoginMode {
                Button("Forgot Password?") {
                    showForgotPassword = true
                }
                .font(AppFonts.bodyMedium)
                .foregroundStyle(AppColors.primaryLight)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.toggleMode()
                }
            } label: {
                Text(viewModel.isLoginMode ? "Don't have an account? " : "Already have an account? ")
                    .foregroundStyle(AppColors.textSecondary)
                + Text(viewModel.isLoginMode ? "Sign Up" : "Sign In")
                    .foregroundStyle(AppColors.primaryLight)
                    .bold()
            }
            .font(AppFonts.bodyMedium)
            .padding(.top, 4)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColors.surfaceDark.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppColors.surfaceLighter.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

#Preview {
    AuthView()
        .environment(AppDependencies.shared.sessionManager)
}
