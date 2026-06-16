//
//  NotesView.swift
//  SupabaseSwiftUI
//

import SwiftUI

struct NotesView: View {
    @State private var viewModel = NotesViewModel()
    @State private var showAddNote = false
    @State private var noteToDelete: Note?

    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundDark.ignoresSafeArea()

                Group {
                    if viewModel.isLoading && viewModel.notes.isEmpty {
                        ProgressView().tint(AppColors.primaryLight)
                    } else if viewModel.filteredNotes.isEmpty {
                        emptyState
                    } else {
                        notesGrid
                    }
                }

                fab
            }
            .navigationTitle("Notes")
            .toolbarBackground(AppColors.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .searchable(text: $viewModel.query, prompt: "Search notes")
            .navigationDestination(for: Note.self) { note in
                NoteDetailView(note: note, viewModel: viewModel)
            }
        }
        .task { await viewModel.loadNotes() }
        .sheet(isPresented: $showAddNote) {
            AddEditNoteView(viewModel: viewModel, isEdit: false)
        }
        .alert("Delete Note", isPresented: deleteAlertBinding, presenting: noteToDelete) { note in
            Button("Delete", role: .destructive) {
                Task { await viewModel.deleteNote(note) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("This note and its image will be permanently deleted.")
        }
        .loadingOverlay(viewModel.isSaving)
    }

    private var notesGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(viewModel.filteredNotes) { note in
                    NavigationLink(value: note) {
                        NoteCardView(
                            note: note,
                            imageURL: note.imageUrl.map { viewModel.getImageUrl(path: $0) },
                            onDelete: { noteToDelete = note }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .padding(.bottom, 90)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 56))
                .foregroundStyle(AppColors.textMuted)
            Text("No notes yet")
                .font(AppFonts.titleLarge)
                .foregroundStyle(AppColors.textPrimary)
            Text("Tap the + button to add your first note")
                .font(AppFonts.bodyMedium)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }

    private var fab: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    viewModel.prepareForAdd()
                    showAddNote = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 64, height: 64)
                        .background(Circle().fill(AppColors.primaryMain))
                        .shadow(color: AppColors.primaryMain.opacity(0.5), radius: 12, y: 6)
                }
                .padding(24)
            }
        }
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { noteToDelete != nil },
            set: { if !$0 { noteToDelete = nil } }
        )
    }
}

#Preview {
    NotesView()
        .environment(AppDependencies.shared.sessionManager)
}
