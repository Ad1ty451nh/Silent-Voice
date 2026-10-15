//
//  ComingSoonView.swift
//  Silent Voice
//
//  Created by Adityasinh on 30/09/26.
//
import SwiftUI

/// Temporary placeholder for tabs we haven't built yet.
/// Custom replacement for ContentUnavailableView (iOS 17 only).
struct ComingSoonView: View {
    let title: String
    let symbol: String
    let message: String

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.m) {
                Image(systemName: symbol)
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.Palette.primary)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.Palette.textPrimary)

                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.Palette.textSecondary)
            }
            .padding(Theme.Spacing.l)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.Palette.background)
            .accessibilityElement(children: .combine)
            .navigationTitle(title)
        }
    }
}
