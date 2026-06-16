//
//  Note.swift
//  SupabaseSwiftUI
//

import Foundation

struct Note: Codable, Identifiable, Equatable, Hashable {
    var id: String
    let userId: String
    var title: String
    var content: String
    var imageUrl: String?
    var createdAt: String
    var updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, content
        case userId = "user_id"
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension Note {
    /// `YYYY-MM-DD` portion of `updatedAt` for compact display.
    var updatedDateShort: String {
        String(updatedAt.prefix(10))
    }

    /// `YYYY-MM-DD HH:MM` portion of `updatedAt` for the detail header.
    var updatedDateTime: String {
        let datePart = updatedAt.prefix(10)
        let timePart = updatedAt.dropFirst(11).prefix(5)
        guard !timePart.isEmpty else { return String(datePart) }
        return "\(datePart) \(timePart)"
    }
}
