//
//  ScenarioPracticeView.swift
//  Silent Voice
//
//  Created by Adityasinh on 01/10/26.
//

import SwiftUI

struct ScenarioChoice: Identifiable {
    let id: Int
    let text: String
    let isHelpful: Bool
    let feedback: String
}

struct Scenario: Identifiable {
    let id: Int
    let title: String
    let situation: String
    let choices: [ScenarioChoice]
}

enum ScenarioLibrary {
    static let all: [Scenario] = [
        Scenario(
            id: 0,
            title: "The pause",
            situation: "You ask, “Would you like water or juice?” The person doesn't answer right away. Several seconds pass.",
            choices: [
                ScenarioChoice(
                    id: 0,
                    text: "Say, “I'll just get you water,” and move on.",
                    isHelpful: false,
                    feedback: "That makes the choice for them. A pause usually means they're still forming their answer."
                ),
                ScenarioChoice(
                    id: 1,
                    text: "Stay relaxed, keep looking at them, and wait.",
                    isHelpful: true,
                    feedback: "Time is the most useful thing you can give. They may be finding the words or choosing a phrase."
                ),
                ScenarioChoice(
                    id: 2,
                    text: "Repeat the question a little louder.",
                    isHelpful: false,
                    feedback: "Repeating adds pressure and can interrupt their effort. Louder doesn't help if hearing isn't the issue."
                )
            ]
        ),
        Scenario(
            id: 1,
            title: "Half a sentence",
            situation: "They're typing a message. It's taking a while, and you think you know where it's going.",
            choices: [
                ScenarioChoice(
                    id: 0,
                    text: "Finish it for them to save time.",
                    isHelpful: false,
                    feedback: "Even a correct guess takes the sentence away from them. It's their message."
                ),
                ScenarioChoice(
                    id: 1,
                    text: "Wait until it's spoken, then respond to what they actually said.",
                    isHelpful: true,
                    feedback: "Your guess might have been off, and even if it wasn't, they got to say it themselves."
                ),
                ScenarioChoice(
                    id: 2,
                    text: "Pick up the device to help them go faster.",
                    isHelpful: false,
                    feedback: "Their device is part of their voice. Don't take or touch it without asking."
                )
            ]
        ),
        Scenario(
            id: 2,
            title: "Too many questions",
            situation: "You want to know whether they're hungry, tired, or want to go outside.",
            choices: [
                ScenarioChoice(
                    id: 0,
                    text: "Ask all three in one go.",
                    isHelpful: false,
                    feedback: "Stacked questions are hard to hold in mind while putting an answer together."
                ),
                ScenarioChoice(
                    id: 1,
                    text: "Ask one, “Are you hungry?”, and wait for the answer.",
                    isHelpful: true,
                    feedback: "One clear question at a time gives them room to answer on their own terms."
                ),
                ScenarioChoice(
                    id: 2,
                    text: "Check with the person next to you instead.",
                    isHelpful: false,
                    feedback: "Go to the source. They can tell you themselves."
                )
            ]
        ),
        Scenario(
            id: 3,
            title: "Talking over them",
            situation: "A relative asks you, “Does she understand all this?” while she's sitting right there.",
            choices: [
                ScenarioChoice(
                    id: 0,
                    text: "Answer the relative and carry on.",
                    isHelpful: false,
                    feedback: "Talking about someone in front of them leaves them out. Understanding and speaking are different things."
                ),
                ScenarioChoice(
                    id: 1,
                    text: "Turn to her: “Would you like to answer that yourself?”",
                    isHelpful: true,
                    feedback: "That includes her in the conversation and lets her decide how to respond."
                ),
                ScenarioChoice(
                    id: 2,
                    text: "Ignore the question and change the subject.",
                    isHelpful: false,
                    feedback: "Dodging leaves everyone uncomfortable. Including her is kinder and clearer."
                )
            ]
        )
    ]
}

/// Lightweight practice: read a moment, pick a response, see why it helps. No scores to chase.
struct ScenarioPracticeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let scenarios = ScenarioLibrary.all

    @State private var index = 0
    @State private var pickedID: Int?
    @State private var helpfulCount = 0

    private var isFinished: Bool {
        index >= scenarios.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                if isFinished {
                    finishedView
                } else {
                    scenarioView(scenarios[index])
                }
            }
            .padding(Theme.Spacing.m)
        }
        .background(Theme.Palette.background)
        .navigationTitle("Practice")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Scenario

    private func scenarioView(_ scenario: Scenario) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.l) {
            Text("Scenario \(index + 1) of \(scenarios.count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.Palette.textSecondary)

            VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                Text(scenario.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.Palette.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text(scenario.situation)
                    .font(.title3)
                    .foregroundStyle(Theme.Palette.textPrimary)
            }
            .padding(Theme.Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SoftCardBackground(tint: Theme.Palette.primary, cornerRadius: Theme.Radius.card))

            Text("What would you do?")
                .font(.headline)
                .foregroundStyle(Theme.Palette.textPrimary)

            VStack(spacing: Theme.Spacing.m) {
                ForEach(scenario.choices) { choice in
                    choiceButton(choice)
                }
            }

            if let pickedID, let picked = scenario.choices.first(where: { $0.id == pickedID }) {
                feedbackCard(picked)

                Button(index == scenarios.count - 1 ? "Finish" : "Next scenario") {
                    advance()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    private func choiceButton(_ choice: ScenarioChoice) -> some View {
        let isPicked = pickedID == choice.id
        let hasPicked = pickedID != nil
        let accent: Color = choice.isHelpful ? Theme.Palette.success : Theme.Palette.warning

        return Button {
            pick(choice)
        } label: {
            HStack(spacing: Theme.Spacing.m) {
                Text(choice.text)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Theme.Palette.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                // A shape cue for the pick, so it never depends on color alone.
                if isPicked {
                    Image(systemName: choice.isHelpful ? "checkmark.circle.fill" : "arrow.uturn.backward.circle.fill")
                        .font(.title3)
                        .foregroundStyle(accent)
                        .accessibilityHidden(true)
                }
            }
            .padding(Theme.Spacing.m)
            .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget, alignment: .leading)
            .background(
                SoftCardBackground(
                    tint: isPicked ? accent : Theme.Palette.primary,
                    cornerRadius: Theme.Radius.card,
                    isEmphasized: isPicked
                )
            )
            .opacity(hasPicked && !isPicked ? 0.55 : 1)
        }
        .buttonStyle(PhraseCardPressStyle())
        .disabled(hasPicked)
    }

    private func feedbackCard(_ choice: ScenarioChoice) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(choice.isHelpful ? "This helps" : "Another way to see it")
                .font(.headline)
                .foregroundStyle(Theme.Palette.textPrimary)

            Text(choice.feedback)
                .font(.body)
                .foregroundStyle(Theme.Palette.textPrimary)
        }
        .padding(Theme.Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            SoftCardBackground(
                tint: choice.isHelpful ? Theme.Palette.success : Theme.Palette.warning,
                cornerRadius: Theme.Radius.card
            )
        )
        .accessibilityElement(children: .combine)
    }

    // MARK: - Finished

    private var finishedView: some View {
        VStack(spacing: Theme.Spacing.m) {
            EmptyStateView(
                symbol: "heart.fill",
                title: "Nice work",
                message: "You picked the supportive response \(helpfulCount) of \(scenarios.count) times. There's no score to chase. Real conversations are the real practice, and the best guide is the person you're talking with."
            )

            Button("Practice again") {
                restart()
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("Done") {
                dismiss()
            }
            .font(.headline)
            .foregroundStyle(Theme.Palette.primary)
            .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget)
        }
    }

    // MARK: - Actions

    private func pick(_ choice: ScenarioChoice) {
        guard pickedID == nil else { return }
        if choice.isHelpful {
            helpfulCount += 1
            Haptics.success()
        } else {
            Haptics.soft()
        }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            pickedID = choice.id
        }
    }

    private func advance() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            pickedID = nil
            index += 1
        }
    }

    private func restart() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            index = 0
            pickedID = nil
            helpfulCount = 0
        }
    }
}
