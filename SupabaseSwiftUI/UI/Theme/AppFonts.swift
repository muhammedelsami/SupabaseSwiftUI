//
//  AppFonts.swift
//  SupabaseSwiftUI
//
//  Typography tokens used across the app.
//

import SwiftUI

enum AppFonts {
    static let displayLarge = Font.system(size: 30, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 24, weight: .bold, design: .rounded)
    static let titleLarge = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let titleMedium = Font.system(size: 17, weight: .semibold)
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let caption = Font.system(size: 12, weight: .medium)
}
