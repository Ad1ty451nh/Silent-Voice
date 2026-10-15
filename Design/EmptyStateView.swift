//
//  SwiftUIView.swift
//  Silent Voice
//
//  Created by Adityasinh on 01/10/26.
//

import SwiftUI

/// Reusable empty state. Replaces the temporary ComingSoonView.
struct EmptyStateView: View {
    let symbol: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Theme.Spacing.m) {
            Image(systemName: symbol)
                .font(.system(size: 52))
                .foregroundStyle(Theme.Palette.primary)
                .accessibilityHidden(true)

            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.Palette.textPrimary)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body)
                .foregroundStyle(Theme.Palette.textSecondary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, Theme.Spacing.s)
            }
        }
        .padding(Theme.Spacing.l)
        .frame(maxWidth: .infinity)
    }
}

/// Main call-to-action button style used across the app.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.white)
            .padding(.horizontal, Theme.Spacing.l)
            .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget)
            .background(Theme.Palette.primary, in: RoundedRectangle(cornerRadius: Theme.Radius.button))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
