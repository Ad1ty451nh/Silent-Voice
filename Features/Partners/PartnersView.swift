//
//  PartnersView.swift
//  Silent Voice
//
//  Created by Adityasinh on 01/10/26.
//

import SwiftUI

private struct Principle: Identifiable {
    let symbol: String
    let title: String
    let detail: String
    let tint: Color
    var id: String { title }
}

struct PartnersView: View {
    private let principles: [Principle] = [
        Principle(
            symbol: "clock.fill",
            title: "Give them time",
            detail: "Silence often means the person is still putting a message together. Wait before filling it.",
            tint: Theme.Palette.primary
        ),
        Principle(
            symbol: "text.bubble.fill",
            title: "Don't finish their sentence",
            detail: "Let them complete their own message, even if you think you know where it's going.",
            tint: Theme.Palette.accent
        ),
        Principle(
            symbol: "questionmark.bubble.fill",
            title: "Ask one question at a time",
            detail: "Give them room to answer before you ask the next one.",
            tint: Theme.Palette.info
        ),
        Principle(
            symbol: "person.fill",
            title: "Don't answer for them",
            detail: "Speak to the person, not about them. If they're asked something, let them answer.",
            tint: Theme.Palette.success
        ),
        Principle(
            symbol: "eye.fill",
            title: "Look at the person, not only the device",
            detail: "Your eye contact and attention show you're really listening.",
            tint: Theme.Palette.warning
        ),
        Principle(
            symbol: "hourglass",
            title: "Respect communication that takes longer",
            detail: "Typing or choosing phrases can take more time. Slower isn't worse.",
            tint: Theme.Palette.primary
        ),
        Principle(
            symbol: "heart.fill",
            title: "Ask what works for them",
            detail: "Everyone communicates differently. Ask how they'd like you to ask, wait, and help.",
            tint: Theme.Palette.accent
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                    Text("A conversation takes two. A few small habits help it feel like one.")
                        .font(.title3)
                        .foregroundStyle(Theme.Palette.textPrimary)

                    NavigationLink {
                        ScenarioPracticeView()
                    } label: {
                        HStack(spacing: Theme.Spacing.m) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.title)
                                .foregroundStyle(Theme.Palette.primary)
                                .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text("Try a scenario")
                                    .font(.headline)
                                    .foregroundStyle(Theme.Palette.textPrimary)
                                Text("Four short moments. Choose what you'd do.")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.Palette.textSecondary)
                            }
                            .multilineTextAlignment(.leading)

                            Spacer(minLength: 0)

                            Image(systemName: "chevron.right")
                                .font(.headline)
                                .foregroundStyle(Theme.Palette.primary)
                                .accessibilityHidden(true)
                        }
                        .padding(Theme.Spacing.m)
                        .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget)
                        .background(SoftCardBackground(tint: Theme.Palette.primary, cornerRadius: Theme.Radius.card, isEmphasized: true))
                    }
                    .buttonStyle(PhraseCardPressStyle())
                    .accessibilityElement(children: .combine)

                    VStack(alignment: .leading, spacing: Theme.Spacing.m) {
                        Text("Principles")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Theme.Palette.textPrimary)
                            .accessibilityAddTraits(.isHeader)

                        ForEach(principles) { principle in
                            PrincipleCard(principle: principle)
                        }
                    }

                    Text("This is general guidance, not therapy or medical advice. Everyone communicates differently, and the best expert on how to communicate with someone is that person.")
                        .font(.footnote)
                        .foregroundStyle(Theme.Palette.textSecondary)
                }
                .padding(Theme.Spacing.m)
            }
            .background(Theme.Palette.background)
            .navigationTitle("Partners")
        }
    }
}

private struct PrincipleCard: View {
    let principle: Principle

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.m) {
            Image(systemName: principle.symbol)
                .font(.title3)
                .foregroundStyle(principle.tint)
                .frame(width: 44, height: 44)
                .background(principle.tint.opacity(0.18), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(principle.title)
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.textPrimary)

                Text(principle.detail)
                    .font(.body)
                    .foregroundStyle(Theme.Palette.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SoftCardBackground(tint: principle.tint, cornerRadius: Theme.Radius.card))
        .accessibilityElement(children: .combine)
    }
}
