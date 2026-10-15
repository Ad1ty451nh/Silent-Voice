//
//  SentenceCard.swift
//  Silent Voice
//
//  Created by Adityasinh on 01/10/26.
//

import SwiftUI

/// Full-width card for a spoken sentence: tap to speak, star to favorite, menu to edit or delete.
/// Soft pastel surface to match the rest of the app.
struct SentenceCard: View {
    let phrase: Phrase
    let onSpeak: () -> Void
    let onToggleFavorite: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onSpeak) {
                HStack(spacing: Theme.Spacing.m) {
                    // A waveform means this phrase plays a recorded voice.
                    Image(systemName: phrase.voiceFile == nil ? "speaker.wave.2.fill" : "waveform")
                        .foregroundStyle(Theme.Palette.primary)
                        .accessibilityHidden(true)

                    Text(phrase.text)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Theme.Palette.textPrimary)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 0)
                }
                .padding(.vertical, Theme.Spacing.m)
                .padding(.leading, Theme.Spacing.m)
                .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PhraseCardPressStyle())
            .accessibilityLabel(phrase.text)
            .accessibilityHint(phrase.voiceFile == nil ? "Speaks this phrase aloud" : "Plays a recorded voice")

            Button(action: onToggleFavorite) {
                Image(systemName: phrase.isFavorite ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundStyle(phrase.isFavorite ? Theme.Palette.favorite : Theme.Palette.textSecondary)
                    .frame(width: 48, height: Theme.minTouchTarget)
            }
            .accessibilityLabel(phrase.isFavorite ? "Remove from favorites" : "Add to favorites")

            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .foregroundStyle(Theme.Palette.textSecondary)
                    .frame(width: 48, height: Theme.minTouchTarget)
            }
            .accessibilityLabel("More options")
        }
        .background(SoftCardBackground(tint: Theme.Palette.primary, cornerRadius: Theme.Radius.card))
    }
}
