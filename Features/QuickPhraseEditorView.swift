//
//  QuickPhraseEditorView.swift
//  Silent Voice
//
//  Created by Adityasinh on 03/10/26.
//

import SwiftUI

private extension QuickTone {
    var swatchName: String {
        switch self {
        case .yes: "Green"
        case .no, .stop: "Red"
        case .maybe: "Blue"
        case .wait: "Amber"
        case .help: "Violet"
        case .neutral: "Deep violet"
        }
    }

    /// Stop and No share a color, so they share a swatch.
    var swatchKey: QuickTone { self == .stop ? .no : self }
}

/// Add or edit a Quick Speak card: label, optional spoken sentence, optional recorded voice, color.
struct QuickPhraseEditorView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var speech: SpeechService
    @Environment(\.dismiss) private var dismiss
    @StateObject private var voice = VoiceRecorder()

    private static let swatches: [QuickTone] = [.yes, .no, .maybe, .wait, .help, .neutral]

    private let original: QuickPhrase?
    private let sectionID: UUID?

    @State private var label: String
    @State private var spokenText: String
    @State private var tone: QuickTone
    @State private var showDeleteDialog = false

    /// Edit an existing card.
    init(phrase: QuickPhrase) {
        original = phrase
        sectionID = nil
        _label = State(initialValue: phrase.text)
        _spokenText = State(initialValue: phrase.spokenText ?? "")
        _tone = State(initialValue: phrase.tone)
    }

    /// Create a new card in a section.
    init(sectionID: UUID) {
        original = nil
        self.sectionID = sectionID
        _label = State(initialValue: "")
        _spokenText = State(initialValue: "")
        _tone = State(initialValue: .neutral)
    }

    private var cleanLabel: String {
        label.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanSpoken: String {
        spokenText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// What the card will actually say.
    private var spokenPreview: String {
        cleanSpoken.isEmpty ? cleanLabel : cleanSpoken
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("e.g. Water", text: $label)
                        .font(.title3)
                        .foregroundStyle(Theme.Palette.textPrimary)
                } header: {
                    Text("Label")
                } footer: {
                    Text("The short word shown on the card.")
                }
                .listRowBackground(Theme.Palette.surface)

                Section {
                    TextField("Same as label", text: $spokenText, axis: .vertical)
                        .lineLimit(1...4)
                        .font(.title3)
                        .foregroundStyle(Theme.Palette.textPrimary)
                } header: {
                    Text("Says")
                } footer: {
                    Text("Optional. For example, the label “Water” can say “I want water, please.”")
                }
                .listRowBackground(Theme.Palette.surface)

                VoiceRecordingSection(voice: voice)

                Section {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 56), spacing: Theme.Spacing.s)],
                        spacing: Theme.Spacing.s
                    ) {
                        ForEach(Self.swatches, id: \.self) { option in
                            swatch(option)
                        }
                    }
                    .padding(.vertical, Theme.Spacing.xs)
                } header: {
                    Text("Color")
                }
                .listRowBackground(Theme.Palette.surface)

                Section {
                    PhraseCard(
                        title: cleanLabel.isEmpty ? "Preview" : cleanLabel,
                        spoken: spokenPreview,
                        tone: tone,
                        hint: "Plays the preview"
                    ) {
                        Haptics.tap()
                        speech.say(spokenPreview, recording: voice.filename)
                    }
                    .disabled(cleanLabel.isEmpty)
                    .frame(maxWidth: 200)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Preview")
                } footer: {
                    Text("Tap the card to hear it.")
                }

                if original != nil {
                    Section {
                        Button(role: .destructive) {
                            showDeleteDialog = true
                        } label: {
                            Text("Delete Card")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .listRowBackground(Theme.Palette.surface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Palette.background)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(original == nil ? "New Card" : "Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(cleanLabel.isEmpty)
                }
            }
            .confirmationDialog(
                "Delete this card?",
                isPresented: $showDeleteDialog,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let original {
                        store.deleteQuickPhrase(id: original.id)
                        Haptics.warning()
                        dismiss()
                    }
                }
            }
            .onAppear {
                voice.configure(original: original?.voiceFile)
            }
            .onDisappear {
                // Throws away a take that was never saved. After a save this does nothing.
                voice.discard()
            }
        }
    }

    // MARK: - Pieces

    private func swatch(_ option: QuickTone) -> some View {
        let selected = tone.swatchKey == option.swatchKey

        return Circle()
            .fill(option.color)
            .frame(width: 48, height: 48)
            .overlay(
                Circle().strokeBorder(Theme.Palette.textPrimary, lineWidth: selected ? 3 : 0)
            )
            .overlay {
                if selected {
                    Image(systemName: "checkmark")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(option.onColor)
                }
            }
            .frame(minWidth: 56, minHeight: 56)
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.soft()
                tone = option
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(option.swatchName)
            .accessibilityAddTraits(traits(selected: selected))
    }

    private func traits(selected: Bool) -> AccessibilityTraits {
        selected ? [.isButton, .isSelected] : [.isButton]
    }

    // MARK: - Save

    private func save() {
        guard !cleanLabel.isEmpty else { return }
        let spoken: String? = cleanSpoken.isEmpty ? nil : cleanSpoken

        voice.stopRecording()
        let voiceFile = voice.commit()

        if var updated = original {
            updated.text = cleanLabel
            updated.spokenText = spoken
            updated.tone = tone
            updated.voiceFile = voiceFile
            store.updateQuickPhrase(updated)
        } else if let sectionID {
            store.addQuickPhrase(text: cleanLabel, spokenText: spoken, tone: tone, sectionID: sectionID, voiceFile: voiceFile)
        }

        Haptics.success()
        dismiss()
    }
}
