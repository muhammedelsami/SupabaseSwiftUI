//
//  NotesViewModel.swift
//  SupabaseSwiftUI
//

import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class NotesViewModel {
    // List
    var notes: [Note] = []
    var query = ""

    // Editor inputs
    var titleInput = ""
    var contentInput = ""
    var selectedImage: UIImage?
    /// Raw bytes of a newly picked image (nil when the image is unchanged).
    var selectedImageData: Data?
    var selectedNote: Note?

    // UI state
    var isLoading = false
    var isSaving = false
    var successMessage: String?
    var error: String?

    private let notesRepository: NotesRepository
    private let sessionManager: SessionManager

    init() {
        self.notesRepository = AppDependencies.shared.notesRepository
        self.sessionManager = AppDependencies.shared.sessionManager
    }

    init(notesRepository: NotesRepository, sessionManager: SessionManager) {
        self.notesRepository = notesRepository
        self.sessionManager = sessionManager
    }

    var filteredNotes: [Note] {
        let base: [Note]
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            base = notes
        } else {
            base = notes.filter {
                $0.title.localizedCaseInsensitiveContains(trimmed)
                    || $0.content.localizedCaseInsensitiveContains(trimmed)
            }
        }
        return base.sorted { $0.updatedAt > $1.updatedAt }
    }

    // MARK: - Load

    func loadNotes() async {
        guard let userId = sessionManager.currentSession?.userId else { return }
        isLoading = true
        defer { isLoading = false }

        switch await notesRepository.fetchNotes(userId: userId) {
        case .success(let result):
            notes = result
        case .error(let message):
            error = message
        case .loading:
            break
        }
    }

    // MARK: - Editor lifecycle

    func prepareForAdd() {
        selectedNote = nil
        titleInput = ""
        contentInput = ""
        selectedImage = nil
        selectedImageData = nil
    }

    func prepareForEdit(_ note: Note) {
        selectedNote = note
        titleInput = note.title
        contentInput = note.content
        selectedImage = nil
        selectedImageData = nil
    }

    // MARK: - Create

    func addNote() async -> Bool {
        guard let userId = sessionManager.currentSession?.userId else { return false }
        let title = titleInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            error = "Please enter a title."
            return false
        }

        isSaving = true
        defer { isSaving = false }

        let now = ISO8601DateFormatter().string(from: Date())
        let note = Note(
            id: UUID().uuidString,
            userId: userId,
            title: title,
            content: contentInput,
            imageUrl: nil,
            createdAt: now,
            updatedAt: now
        )

        let imageData = selectedImageData ?? selectedImage?.jpegData(compressionQuality: 0.8)

        switch await notesRepository.createNote(note: note, imageData: imageData) {
        case .success:
            successMessage = "Note created."
            await loadNotes()
            return true
        case .error(let message):
            error = message
            return false
        case .loading:
            return false
        }
    }

    // MARK: - Update

    func updateNote() async -> Bool {
        guard let original = selectedNote else { return false }
        let title = titleInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            error = "Please enter a title."
            return false
        }

        isSaving = true
        defer { isSaving = false }

        var updated = original
        updated.title = title
        updated.content = contentInput

        let newImageData = selectedImageData
        // Existing image present, nothing shown and nothing newly picked => remove it.
        let removeImage = (original.imageUrl != nil)
            && selectedImage == nil
            && selectedImageData == nil

        switch await notesRepository.updateNote(
            note: updated,
            newImageData: newImageData,
            removeImage: removeImage
        ) {
        case .success:
            successMessage = "Note updated."
            await loadNotes()
            return true
        case .error(let message):
            error = message
            return false
        case .loading:
            return false
        }
    }

    // MARK: - Delete

    func deleteNote(_ note: Note) async {
        isSaving = true
        defer { isSaving = false }

        switch await notesRepository.deleteNote(note: note) {
        case .success:
            successMessage = "Note deleted."
            notes.removeAll { $0.id == note.id }
        case .error(let message):
            error = message
        case .loading:
            break
        }
    }

    func getImageUrl(path: String) -> URL {
        notesRepository.getImageUrl(path: path)
    }
}
