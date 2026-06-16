//
//  ProfileView.swift
//  SupabaseSwiftUI
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView().tint(AppColors.primaryLight)
                } else {
                    ScrollView {
                        VStack(spacing: 28) {
                            avatar
                            nameSection
                            infoSection
                            actionsCard
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Profile")
            // Native Liquid Glass navigation bar (no forced opaque background).
            .task { await viewModel.loadProfile() }
            .loadingOverlay(viewModel.isSaving)
            .alert("Sign Out", isPresented: $showLogoutAlert) {
                Button("Sign Out", role: .destructive) {
                    Task { await viewModel.logout() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    Task { await viewModel.deleteAccount() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes your account, notes, and images. This cannot be undone.")
            }
        }
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(AppColors.primaryMain.opacity(0.2))
                .frame(width: 100, height: 100)
            Image(systemName: "person.fill")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.primaryLight)
        }
        .padding(.top, 12)
    }

    private var nameSection: some View {
        VStack(spacing: 6) {
            if viewModel.isEditing {
                HStack(spacing: 10) {
                    TextField(
                        "",
                        text: $viewModel.nameInput,
                        prompt: Text("Your name").foregroundColor(AppColors.textMuted)
                    )
                    .font(AppFonts.titleLarge)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColors.surfaceDark)
                    )

                    Button {
                        Task { await viewModel.saveProfile() }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(AppColors.secondaryMain)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    Text(viewModel.profile?.name?.isEmpty == false ? viewModel.profile!.name! : "No name")
                        .font(AppFonts.displayMedium)
                        .foregroundStyle(AppColors.textPrimary)
                    Button {
                        viewModel.toggleEdit()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }

            Text(viewModel.profile?.email ?? "")
                .font(AppFonts.bodyMedium)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("User ID")
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.textMuted)
            Text(viewModel.profile?.id ?? "—")
                .font(AppFonts.bodyMedium)
                .foregroundStyle(AppColors.textSecondary)
                .textSelection(.enabled)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.surfaceDark)
        )
    }

    private var actionsCard: some View {
        VStack(spacing: 0) {
            Button {
                showLogoutAlert = true
            } label: {
                actionRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", tint: AppColors.textPrimary)
            }

            Divider().overlay(AppColors.surfaceLighter)

            Button {
                showDeleteAlert = true
            } label: {
                actionRow(icon: "trash", title: "Delete Account", tint: AppColors.errorMain)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColors.surfaceDark)
        )
    }

    private func actionRow(icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
            Text(title)
                .font(AppFonts.titleMedium)
            Spacer()
        }
        .foregroundStyle(tint)
        .padding(18)
    }
}

#Preview {
    ProfileView()
        .environment(AppDependencies.shared.sessionManager)
}
