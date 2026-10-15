//
//  WelcomeView.swift
//  Silent Voice
//
//  Created by Adityasinh on 03/10/26.
//

import SwiftUI

private struct WelcomePage: Identifiable {
    let id: Int
    let symbol: String
    let title: String
    let message: String
}

/// Three short screens, shown once. Skippable at any point.
struct WelcomeView: View {
    let onFinish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    private let pages: [WelcomePage] = [
        WelcomePage(
            id: 0,
            symbol: "bubble.left.fill",
            title: "Your voice, your way",
            message: "Tap a card to say it out loud. Or type anything and tap the speaker. It's fast, and it works without internet."
        ),
        WelcomePage(
            id: 1,
            symbol: "slider.horizontal.3",
            title: "Make it yours",
            message: "Change the words, colors and categories. Choose places like Home or School. Record a voice for any card if you'd like. You decide how it works."
        ),
        WelcomePage(
            id: 2,
            symbol: "person.2.fill",
            title: "For the people around you",
            message: "The Partners tab has simple tips for family, friends and teachers. Everything you create stays on this device."
        )
    ]

    private var isLast: Bool {
        page == pages.count - 1
    }

    var body: some View {
        ZStack {
            Theme.Palette.background.ignoresSafeArea()

            VStack(spacing: Theme.Spacing.m) {
                HStack {
                    Spacer()
                    if !isLast {
                        Button("Skip") {
                            onFinish()
                        }
                        .font(.headline)
                        .foregroundStyle(Theme.Palette.textSecondary)
                        .frame(minWidth: Theme.minTouchTarget, minHeight: Theme.minTouchTarget)
                    }
                }
                .frame(height: Theme.minTouchTarget)

                TabView(selection: $page) {
                    ForEach(pages) { item in
                        pageView(item)
                            .tag(item.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                dots

                Button(isLast ? "Get started" : "Next") {
                    advance()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(Theme.Spacing.l)
        }
    }

    // MARK: - Pieces

    private func pageView(_ item: WelcomePage) -> some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.l) {
                Image(systemName: item.symbol)
                    .font(.system(size: 72))
                    .foregroundStyle(Theme.Palette.primary)
                    .frame(width: 150, height: 150)
                    .background(Theme.Palette.surfaceElevated, in: Circle())
                    .accessibilityHidden(true)

                Text(item.title)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Theme.Palette.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(item.message)
                    .font(.title3)
                    .foregroundStyle(Theme.Palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.Spacing.xl)
            .padding(.horizontal, Theme.Spacing.s)
            .frame(maxWidth: .infinity)
        }
    }

    private var dots: some View {
        HStack(spacing: Theme.Spacing.s) {
            ForEach(pages) { item in
                Circle()
                    .fill(item.id == page ? Theme.Palette.primary : Theme.Palette.border)
                    .frame(width: 10, height: 10)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(page + 1) of \(pages.count)")
    }

    private func advance() {
        Haptics.soft()
        if isLast {
            onFinish()
        } else {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                page += 1
            }
        }
    }
}
