//
//  PhraseCard.swift
//  Silent Voice
//
//  Created by Adityasinh on 01/10/26.
//

import SwiftUI

/// Big tappable communication card. Used by Quick Speak now, My Words later.
/// Soft pastel surface in the tone's color, with dark text for easy reading.
struct PhraseCard: View {
    let title: String
    /// What gets spoken. Shown to VoiceOver users as a hint when it differs from the label.
    let spoken: String
    let tone: QuickTone
    /// Overrides the default VoiceOver hint (used by Quick Speak edit mode).
    var hint: String? = nil
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.bold))
                .textCase(.uppercase)
                .multilineTextAlignment(.center)
                // At accessibility text sizes, show every word instead of cutting it off.
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 4)
                .minimumScaleFactor(0.8)
                .foregroundStyle(Theme.Palette.textPrimary)
                .padding(Theme.Spacing.s)
                .frame(maxWidth: .infinity, minHeight: Theme.quickButtonMinHeight)
                .background(SoftCardBackground(tint: tone.color, cornerRadius: Theme.Radius.button))
        }
        .buttonStyle(PhraseCardPressStyle())
        .accessibilityLabel(title)
        .accessibilityHint(hint ?? (spoken == title ? "Speaks this phrase aloud" : "Says: \(spoken)"))
    }
}

/// Press feedback that respects Reduce Motion.
struct PhraseCardPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
