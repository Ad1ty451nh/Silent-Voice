//
//  QuickPhrase.swift
//  Silent Voice
//
//  Created by Adityasinh on 30/09/26.
//

import SwiftUI

/// Semantic tone for a quick phrase. Drives button color.
enum QuickTone: String, Codable, CaseIterable, Hashable {
    case yes, no, maybe, wait, help, stop, neutral

    var color: Color {
        switch self {
        case .yes: Theme.Palette.success
        case .no, .stop: Theme.Palette.danger
        case .maybe: Theme.Palette.info
        case .wait: Theme.Palette.warning
        case .help: Theme.Palette.primary
        case .neutral: Theme.Palette.primaryDark
        }
    }

    /// Text color chosen for contrast on each background.
    /// White on the sage/amber/blue fills is too weak, so those use dark text.
    var onColor: Color {
        switch self {
        case .yes, .wait, .maybe: Theme.Palette.textPrimary
        case .no, .stop, .help, .neutral: .white
        }
    }
}

struct QuickPhrase: Identifiable, Codable, Hashable {
    var id = UUID()
    /// Short label shown on the card.
    var text: String
    /// Optional full sentence to speak instead of the label (e.g. label "Water", spoken "I want water.").
    var spokenText: String? = nil
    var tone: QuickTone = .neutral
    /// File name of a voice recording made on this device. nil = use the system voice.
    var voiceFile: String? = nil

    /// What actually gets spoken. Falls back to the label.
    var spoken: String {
        let clean = spokenText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return clean.isEmpty ? text : clean
    }
}

/// A named group of quick phrases, e.g. "Simple Words" or "Requests".
struct QuickSection: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var phrases: [QuickPhrase]
}
