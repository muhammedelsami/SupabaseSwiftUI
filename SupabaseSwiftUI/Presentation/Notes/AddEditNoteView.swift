//
//  AddEditNoteView.swift
//  SupabaseSwiftUI
//

import SwiftUI
import PhotosUI
import Kingfisher

struct AddEditNoteView: View {
    @Bindable var viewModel: NotesViewModel
    let isEdit: Bool

    @Environment(\.dismiss) private var dismiss
    @State private var photoItem: PhotosPickerItem?

    private var canSave: Bool {
        !viewModel.titleInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        imageArea
                        fields
                    }
                    .padding(20)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(isEdit ? "Edit Note" : "New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.textSecondary)
                }
                if canSave {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") { save() }
                            .bold()
                            .foregroundStyle(AppColors.primaryLight)
                    }
                }
            }
            .loadingOverlay(viewModel.isSaving)
            .task { await loadExistingImageIfNeeded() }
            .onChange(of: photoItem) { _, newItem in
                Task { await loadPickedImage(newItem) }
            }
        }
    }

    // MARK: - Image

    private var imageArea: some View {
        Group {
            if let image = viewModel.selectedImage {
                ZStack(alignment: .bottomTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    Button {
                        viewModel.selectedImage = nil
                        viewModel.selectedImageData = nil
                        photoItem = nil
                    } label: {
                        Label("Remove", systemImage: "trash")
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(AppColors.errorMain))
                    }
                    .padding(12)
                }
            } else {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    VStack(spacing: 10) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(AppColors.textMuted)
                        Text("Add Image")
                            .font(AppFonts.bodyMedium)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AppColors.surfaceDark)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(AppColors.surfaceLighter, style: StrokeStyle(lineWidth: 1, dash: [6]))
                            )
                    )
                }
            }
        }
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField(
                "",
                text: $viewModel.titleInput,
                prompt: Text("Title").foregroundColor(AppColors.textMuted)
            )
            .font(AppFonts.displayLarge)
            .foregroundStyle(AppColors.textPrimary)

            Divider().overlay(AppColors.surfaceLighter)

            ZStack(alignment: .topLeading) {
                if viewModel.contentInput.isEmpty {
                    Text("Write something…")
                        .font(AppFonts.bodyLarge)
                        .foregroundStyle(AppColors.textMuted)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
                TextEditor(text: $viewModel.contentInput)
                    .font(AppFonts.bodyLarge)
                    .foregroundStyle(AppColors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 220)
            }
        }
    }

    // MARK: - Actions

    private func save() {
        Task {
            let ok = isEdit ? await viewModel.updateNote() : await viewModel.addNote()
            if ok { dismiss() }
        }
    }

    private func loadPickedImage(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            viewModel.selectedImageData = data
            viewModel.selectedImage = image
        }
    }

    /// When editing, pull the existing remote image into `selectedImage` so an
    /// untouched image is preserved and an explicit "Remove" can be detected.
    private func loadExistingImageIfNeeded() async {
        guard isEdit,
              viewModel.selectedImage == nil,
              let path = viewModel.selectedNote?.imageUrl else { return }
        let url = viewModel.getImageUrl(path: path)
        let result = try? await KingfisherManager.shared.retrieveImage(with: url)
        if let image = result?.image, viewModel.selectedImageData == nil {
            viewModel.selectedImage = image
        }
    }
}
