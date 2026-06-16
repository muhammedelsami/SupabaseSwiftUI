//
//  NotesRepositoryImpl.swift
//  SupabaseSwiftUI
//

import Foundation
import Supabase

final class NotesRepositoryImpl: NotesRepository {
    private let client: SupabaseClient
    private var bucket: String { SupabaseConfig.notesBucket }

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Read

    func fetchNotes(userId: String) async -> Resource<[Note]> {
        do {
            let notes: [Note] = try await client
                .from("notes")
                .select()
                .eq("user_id", value: userId)
                .order("updated_at", ascending: false)
                .execute()
                .value
            return .success(notes)
        } catch {
            return .error(error.localizedDescription)
        }
    }

    // MARK: - Create

    func createNote(note: Note, imageData: Data?) async -> Resource<Void> {
        do {
            var note = note
            if let imageData {
                let path = storagePath(userId: note.userId, noteId: note.id)
                try await upload(path: path, data: imageData)
                note.imageUrl = path
            }
            try await client.from("notes").insert(note).execute()
            return .success(())
        } catch {
            return .error(error.localizedDescription)
        }
    }

    // MARK: - Update

    func updateNote(note: Note, newImageData: Data?, removeImage: Bool) async -> Resource<Void> {
        do {
            var finalImageUrl = note.imageUrl

            if removeImage {
                if let existing = note.imageUrl {
                    try? await removeFromStorage(path: existing)
                }
                finalImageUrl = nil
            } else if let newImageData {
                if let existing = note.imageUrl {
                    try? await removeFromStorage(path: existing)
                }
                let path = storagePath(userId: note.userId, noteId: note.id)
                try await upload(path: path, data: newImageData)
                finalImageUrl = path
            }

            let payload = NoteUpdatePayload(
                title: note.title,
                content: note.content,
                imageUrl: finalImageUrl
            )
            try await client
                .from("notes")
                .update(payload)
                .eq("id", value: note.id)
                .execute()
            return .success(())
        } catch {
            return .error(error.localizedDescription)
        }
    }

    // MARK: - Delete

    func deleteNote(note: Note) async -> Resource<Void> {
        do {
            // Storage object is removed first, then the database row.
            if let path = note.imageUrl {
                try? await removeFromStorage(path: path)
            }
            try await client.from("notes").delete().eq("id", value: note.id).execute()
            return .success(())
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func deleteAllUserData(userId: String) async -> Resource<Void> {
        do {
            let notes: [Note] = try await client
                .from("notes")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value

            let paths = notes.compactMap(\.imageUrl)
            if !paths.isEmpty {
                try? await client.storage.from(bucket).remove(paths: paths)
            }

            try await client.from("notes").delete().eq("user_id", value: userId).execute()
            return .success(())
        } catch {
            return .error(error.localizedDescription)
        }
    }

    // MARK: - Storage helpers

    func getImageUrl(path: String) -> URL {
        (try? client.storage.from(bucket).getPublicURL(path: path)) ?? SupabaseConfig.url
    }

    private func storagePath(userId: String, noteId: String) -> String {
        "\(userId)/\(noteId)/image.jpg"
    }

    private func upload(path: String, data: Data) async throws {
        try await client.storage.from(bucket).upload(
            path,
            data: data,
            options: FileOptions(contentType: "image/jpeg", upsert: true)
        )
    }

    private func removeFromStorage(path: String) async throws {
        try await client.storage.from(bucket).remove(paths: [path])
    }
}

/// Partial payload sent on update so server-managed columns (id, user_id,
/// created_at) and the updated_at trigger are left untouched.
private struct NoteUpdatePayload: Encodable {
    let title: String
    let content: String
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case title, content
        case imageUrl = "image_url"
    }
}
