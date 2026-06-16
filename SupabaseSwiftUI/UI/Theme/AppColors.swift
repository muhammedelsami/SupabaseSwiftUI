//
//  AppColors.swift
//  SupabaseSwiftUI
//
//  Central color tokens for the dark-mode-only premium theme.
//

import SwiftUI

enum AppColors {
    static let backgroundDark = Color(hex: 0x0F172A)
    static let surfaceDark = Color(hex: 0x1E293B)
    static let surfaceLighter = Color(hex: 0x334155)

    static let primaryMain = Color(hex: 0x4F46E5)
    static let primaryLight = Color(hex: 0x6366F1)
    static let primaryDark = Color(hex: 0x4338CA)

    static let textPrimary = Color(hex: 0xF8FAFC)
    static let textSecondary = Color(hex: 0x94A3B8)
    static let textMuted = Color(hex: 0x64748B)

    static let errorMain = Color(hex: 0xEF4444)
    static let secondaryMain = Color(hex: 0x10B981)

    /// Accent used behind the auth screen gradient.
    static let indigoNight = Color(hex: 0x1E1B4B)
}

extension Color {
    /// Build a `Color` from a 0xRRGGBB integer literal.
    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
