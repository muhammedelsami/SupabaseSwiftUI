//
//  SupabaseConfig.swift
//  SupabaseSwiftUI
//
//  Reads Supabase credentials from Info.plist (populated via build settings).
//

import Foundation

struct SupabaseConfig {
    /// Host only (no scheme), e.g. `abcdxyz.supabase.co`. Stored in Secrets.xcconfig
    /// because `.xcconfig` treats `//` as a comment, so a full URL can't live there.
    static let url: URL = {
        guard
            let rawHost = Bundle.main.infoDictionary?["SUPABASE_HOST"] as? String
        else {
            fatalError("SUPABASE_HOST is missing. Copy Secrets.example.xcconfig to Secrets.xcconfig and fill it in.")
        }
        let host = rawHost.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !host.isEmpty,
            host != "YOUR_PROJECT.supabase.co",
            let url = URL(string: "https://\(host)")
        else {
            fatalError("SUPABASE_HOST is not set. Edit Secrets.xcconfig with your project host (e.g. abcdxyz.supabase.co).")
        }
        return url
    }()

    static let anonKey: String = {
        let key = (Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, key != "YOUR_SUPABASE_ANON_KEY" else {
            fatalError("SUPABASE_ANON_KEY is not set. Edit Secrets.xcconfig with your project anon key.")
        }
        return key
    }()

    static let redirectScheme = "notesapp"
    static let resetPasswordRedirect = URL(string: "notesapp://reset-password")!
    static let notesBucket = "notes-images"
}
