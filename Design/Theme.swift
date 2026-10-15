//
//  Theme.swift
//  Silent Voice
//
//  Created by Adityasinh on 30/09/26.
//

import SwiftUI

extension Color {
    /// Create a color from a 0xRRGGBB value.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

enum Theme {
    enum Palette {
        static let primary = Color(hex: 0x65558F)
        static let primaryDark = Color(hex: 0x40365F)
        static let accent = Color(hex: 0xE98273)
        static let accentSoft = Color(hex: 0xF6D8D3)

        static let background = Color(hex: 0xFAF8F5)
        static let surface = Color(hex: 0xFFFFFF)
        static let surfaceElevated = Color(hex: 0xF0ECF5)

        static let textPrimary = Color(hex: 0x242228)
        static let textSecondary = Color(hex: 0x6E6875)
        /// Soft, decorative border for cards.
        static let border = Color(hex: 0xDDD8E2)
        /// Stronger border for text fields. About 3.4:1 on the background, so inputs are easy to see.
        static let fieldBorder = Color(hex: 0x8B8594)

        static let success = Color(hex: 0x6FA47A)
        static let danger = Color(hex: 0xC95F62)
        static let warning = Color(hex: 0xD99A45)
        static let info = Color(hex: 0x668CB8)
        /// Darker amber for the favorite star so it stays readable on white.
        static let favorite = Color(hex: 0xB87A1E)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let card: CGFloat = 22
        static let button: CGFloat = 20
    }

    /// Apple's minimum is 44pt. AAC users need bigger.
    static let minTouchTarget: CGFloat = 60
    static let quickButtonMinHeight: CGFloat = 110
}
