//
//  NotesRepository.swift
//  SupabaseSwiftUI
//

import Foundation

protocol NotesRepository {
    func fetchNotes(userId: String) async -> Resource<[Note]>
    func createNote(note: Note, imageData: Data?) async -> Resource<Void>
    func updateNote(note: Note, newImageData: Data?, removeImage: Bool) async -> Resource<Void>
    func deleteNote(note: Note) async -> Resource<Void>
    func deleteAllUserData(userId: String) async -> Resource<Void>
    func getImageUrl(path: String) -> URL
}
