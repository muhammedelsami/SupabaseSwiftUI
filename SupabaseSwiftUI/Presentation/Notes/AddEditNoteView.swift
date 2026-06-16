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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                    contentField
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppColors.backgroundDark.ignoresSafeArea())
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            // Native Liquid Glass navigation bar; kept transparent so the hero
            // image extends underneath it (matches NoteDetailView).
            .toolbarBackground(.hidden, for: .navigationBar)
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
            .alert(
                "Couldn't save note",
                isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { if !$0 { viewModel.error = nil } }
                ),
                presenting: viewModel.error
            ) { _ in
                Button("OK", role: .cancel) { viewModel.error = nil }
            } message: { message in
                Text(message)
            }
            .task { await loadExistingImageIfNeeded() }
            .onChange(of: photoItem) { _, newItem in
                Task { await loadPickedImage(newItem) }
            }
        }
    }

    // MARK: - Hero (full-bleed, mirrors NoteDetailView)

    private var hero: some View {
        ZStack(alignment: .bottom) {
            heroBackground

            // Bottom fade into the page background.
            LinearGradient(
                colors: [.clear, AppColors.backgroundDark],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 350)
            .allowsHitTesting(false)

            // Overlaid badge + editable title (leading) and image controls (trailing).
            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(isEdit ? "Edit Note" : "New Note")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(AppColors.primaryMain))
                        // Let taps on the badge fall through to the empty-state picker.
                        .allowsHitTesting(false)

                    TextField(
                        "",
                        text: $viewModel.titleInput,
                        prompt: Text("Title").foregroundColor(.white.opacity(0.6)),
                        axis: .vertical
                    )
                    .font(AppFonts.displayLarge)
                    .foregroundStyle(.white)
                    .lineLimit(1...3)
                }

                Spacer(minLength: 8)

                // Change / remove controls only once an image is present; while
                // empty the whole background acts as the picker (see heroBackground).
                if viewModel.selectedImage != nil {
                    VStack(spacing: 8) {
                        Button {
                            viewModel.selectedImage = nil
                            viewModel.selectedImageData = nil
                            photoItem = nil
                        } label: {
                            Image(systemName: "trash")
                                .font(AppFonts.caption)
                                .foregroundStyle(AppColors.textPrimary)
                                .padding(10)
                                .background(Circle().fill(AppColors.errorMain))
                        }

                        PhotosPicker(selection: $photoItem, matching: .images) {
                            Image(systemName: "photo")
                                .font(AppFonts.caption)
                                .foregroundStyle(AppColors.textPrimary)
                                .padding(10)
                                .background(Circle().fill(AppColors.primaryMain))
                        }
                    }
                }
            }
            .padding(20)
        }
        .frame(height: 350)
        .frame(maxWidth: .infinity)
    }

    /// Picked image — laid out via a fixed-size container + overlay so the
    /// scaled image is clipped and never widens the layout — or a fully
    /// tappable "Add Image" gradient that opens the photo picker.
    @ViewBuilder
    private var heroBackground: some View {
        if let image = viewModel.selectedImage {
            Color.clear
                .frame(height: 350)
                .frame(maxWidth: .infinity)
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
        } else {
            PhotosPicker(selection: $photoItem, matching: .images) {
                ZStack {
                    LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.surfaceDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(spacing: 10) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(AppColors.textPrimary)
                        Text("Add Image")
                            .font(AppFonts.bodyMedium)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .frame(height: 350)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var contentField: some View {
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
