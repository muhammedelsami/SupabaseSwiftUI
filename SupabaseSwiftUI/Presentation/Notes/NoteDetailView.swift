//
//  NoteDetailView.swift
//  SupabaseSwiftUI
//

import SwiftUI
import Kingfisher

struct NoteDetailView: View {
    let note: Note
    @Bindable var viewModel: NotesViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var showEdit = false
    @State private var showDeleteAlert = false

    /// Reflect edits made through the view model without leaving the screen.
    private var currentNote: Note {
        viewModel.notes.first { $0.id == note.id } ?? note
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero
                VStack(alignment: .leading, spacing: 16) {
                    Text("Last updated: \(currentNote.updatedDateTime)")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textMuted)

                    Text(currentNote.content)
                        .font(AppFonts.bodyLarge)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)
        }
        .background(AppColors.backgroundDark.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    viewModel.prepareForEdit(currentNote)
                    showEdit = true
                } label: {
                    Image(systemName: "pencil")
                }
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(AppColors.errorMain)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $showEdit) {
            AddEditNoteView(viewModel: viewModel, isEdit: true)
        }
        .alert("Delete Note", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteNote(currentNote)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This note and its image will be permanently deleted.")
        }
        .loadingOverlay(viewModel.isSaving)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            if let path = currentNote.imageUrl {
                KFImage(viewModel.getImageUrl(path: path))
                    .resizable()
                    .placeholder { AppColors.surfaceDark }
                    .scaledToFill()
                    .frame(height: 350)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.surfaceDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 350)
            }

            LinearGradient(
                colors: [.clear, AppColors.backgroundDark],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 350)

            VStack(alignment: .leading, spacing: 10) {
                Text("Note")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(AppColors.primaryMain))

                Text(currentNote.title)
                    .font(AppFonts.displayLarge)
                    .foregroundStyle(.white)
                    .lineLimit(3)
            }
            .padding(20)
        }
        .frame(height: 350)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        NoteDetailView(note: .previewSampleNoImage, viewModel: NotesViewModel())
    }
}
