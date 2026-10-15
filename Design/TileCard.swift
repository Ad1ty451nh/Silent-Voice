//
//  TileCard.swift
//  Silent Voice
//
//  Created by Adityasinh on 01/10/26.
//

import SwiftUI

/// Square-ish tile for categories and contexts.
/// Wrap it in a Button or NavigationLink; it handles its own VoiceOver label.
/// Soft pastel surface. A selected tile gets a stronger tint, a thicker border and a checkmark.
struct TileCard: View {
    let symbol: String
    let title: String
    var subtitle: String? = nil
    var tint: Color = Theme.Palette.primary
    var isSelected = false
    var isDashed = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            Image(systemName: symbol)
                .font(.title)
                .foregroundStyle(tint)
                .frame(minHeight: 36)

            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.Palette.textPrimary)
                .multilineTextAlignment(.center)
                // At accessibility text sizes, show every word instead of cutting it off.
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                .minimumScaleFactor(0.8)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.textSecondary)
            }
        }
        .padding(Theme.Spacing.m)
        .frame(maxWidth: .infinity, minHeight: 130)
        .background {
            if isDashed {
                SoftDashedBackground(cornerRadius: Theme.Radius.card)
            } else {
                SoftCardBackground(tint: tint, cornerRadius: Theme.Radius.card, isEmphasized: isSelected)
            }
        }
        .overlay(alignment: .topTrailing) {
            // A shape cue for selection, so it never depends on color alone.
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(tint)
                    .padding(10)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(subtitle.map { "\(title), \($0)" } ?? title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
