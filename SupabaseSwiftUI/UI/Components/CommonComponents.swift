//
//  CommonComponents.swift
//  SupabaseSwiftUI
//
//  Reusable styling pieces shared across screens.
//

import SwiftUI

// MARK: - Primary button

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.titleMedium)
            .foregroundStyle(AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isEnabled ? AppColors.primaryMain : AppColors.surfaceLighter)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Themed text field

struct ThemedField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    var isSecure = false
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType?

    @State private var revealed = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(AppColors.textMuted)
                .frame(width: 20)

            Group {
                if isSecure && !revealed {
                    SecureField("", text: $text, prompt: prompt)
                } else {
                    TextField("", text: $text, prompt: prompt)
                }
            }
            .foregroundStyle(AppColors.textPrimary)
            .textInputAutocapitalization(isSecure || keyboard == .emailAddress ? .never : .sentences)
            .autocorrectionDisabled(isSecure || keyboard == .emailAddress)
            .keyboardType(keyboard)
            .textContentType(textContentType)

            if isSecure {
                Button {
                    revealed.toggle()
                } label: {
                    Image(systemName: revealed ? "eye.slash" : "eye")
                        .foregroundStyle(AppColors.textMuted)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColors.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppColors.surfaceLighter, lineWidth: 1)
                )
        )
    }

    private var prompt: Text {
        Text(title).foregroundColor(AppColors.textMuted)
    }
}

// MARK: - Full-screen loading overlay

struct LoadingOverlay: ViewModifier {
    let isPresented: Bool

    func body(content: Content) -> some View {
        content.overlay {
            if isPresented {
                ZStack {
                    Color.black.opacity(0.45).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(AppColors.textPrimary)
                        .scaleEffect(1.4)
                        .padding(28)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(AppColors.surfaceDark)
                        )
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }
}

extension View {
    func loadingOverlay(_ isPresented: Bool) -> some View {
        modifier(LoadingOverlay(isPresented: isPresented))
    }
}
