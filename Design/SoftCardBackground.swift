//
//  SoftCardBackground.swift
//  Silent Voice
//
//  Created by Adityasinh on 03/10/26.
//

import SwiftUI

/// Soft pastel card surface: tinted gradient, glassy top edge, thin tinted border, gentle colored shadow.
/// Put it behind content with `.background(SoftCardBackground(tint: ...))`.
struct SoftCardBackground: View {
    let tint: Color
    var cornerRadius: CGFloat = Theme.Radius.card
    /// Stronger tint, thicker border and no extra shadow change. Used for selected tiles.
    var isEmphasized = false

    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let strength = isEmphasized ? 1.7 : 1.0
        let highContrast = contrast == .increased

        ZStack {
            // Opaque base carries the shadow, so the shadow never shows through the tint.
            shape
                .fill(Theme.Palette.surface)
                .shadow(color: tint.opacity(0.20), radius: 14, x: 0, y: 6)

            // Pastel tint, fading from the top-left corner.
            shape.fill(
                LinearGradient(
                    colors: [tint.opacity(min(0.30 * strength, 0.55)), tint.opacity(min(0.12 * strength, 0.25))],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Glassy highlight along the top-left edge.
            shape
                .inset(by: 1.5)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.85), Color.white.opacity(0)],
                        startPoint: .topLeading,
                        endPoint: .center
                    ),
                    lineWidth: 1
                )

            // Thin tinted border.
            shape.strokeBorder(
                tint.opacity(highContrast ? 0.85 : (isEmphasized ? 0.9 : 0.32)),
                lineWidth: highContrast ? 2 : (isEmphasized ? 2.5 : 1)
            )
        }
    }
}

/// Soft translucent background with a dashed edge, for the "add" buttons.
struct SoftDashedBackground: View {
    var cornerRadius: CGFloat = Theme.Radius.card

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        shape
            .fill(Theme.Palette.surface.opacity(0.55))
            .overlay(
                shape.strokeBorder(
                    Theme.Palette.fieldBorder.opacity(0.55),
                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 5])
                )
            )
    }
}
