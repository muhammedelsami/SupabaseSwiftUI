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

#if DEBUG
extension Note {
    /// Sample note with an image, for SwiftUI previews.
    static let previewSample = Note(
        id: "preview-1",
        userId: "preview-user",
        title: "Weekend in the mountains",
        content: "Hiked up to the ridge before sunrise and watched the fog roll out of the valley. The trail was quiet and the air was cold enough to see your breath.",
        imageUrl: "https://picsum.photos/seed/note/800/600",
        createdAt: "2026-06-14 08:30:00",
        updatedAt: "2026-06-15 19:45:00"
    )

    /// Sample note without an image, for SwiftUI previews.
    static let previewSampleNoImage = Note(
        id: "preview-2",
        userId: "preview-user",
        title: "Grocery list",
        content: "Milk, eggs, coffee, sourdough, and something green for once.",
        imageUrl: nil,
        createdAt: "2026-06-16 09:00:00",
        updatedAt: "2026-06-16 09:10:00"
    )
}
#endif
