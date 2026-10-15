//
//  PhraseEditorView.swift
//  Silent Voice
//
//  Created by Adityasinh on 01/10/26.
//

import SwiftUI

/// Add or edit a phrase. Used from My Words, category pages, Contexts and the type-to-speak bar.
struct PhraseEditorView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var speech: SpeechService
    @Environment(\.dismiss) private var dismiss
    @StateObject private var voice = VoiceRecorder()

    private let original: Phrase?
    @State private var text: String
    @State private var categoryID: UUID?
    @State private var contextIDs: Set<UUID>

    /// Edit an existing phrase.
    init(phrase: Phrase) {
        original = phrase
        _text = State(initialValue: phrase.text)
        _categoryID = State(initialValue: phrase.categoryID)
        _contextIDs = State(initialValue: phrase.contextIDs)
    }

    /// Create a new phrase. Pass nil to default to the first category.
    /// `text` prefills the phrase (used when saving something typed in Quick Speak).
    init(categoryID: UUID?, contextID: UUID? = nil, text: String = "") {
        original = nil
        _text = State(initialValue: text)
        _categoryID = State(initialValue: categoryID)
        _contextIDs = State(initialValue: contextID.map { Set([$0]) } ?? Set<UUID>())
    }

    private var cleanText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !cleanText.isEmpty && categoryID != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What do you want to say?", text: $text, axis: .vertical)
                        .lineLimit(1...5)
                        .font(.title3)
                        .foregroundStyle(Theme.Palette.textPrimary)

                    Button {
                        Haptics.tap()
                        speech.speak(cleanText)
                    } label: {
                        Label("Hear it", systemImage: "speaker.wave.2.fill")
                    }
                    .disabled(cleanText.isEmpty)
                } header: {
                    Text("Phrase")
                }
                .listRowBackground(Theme.Palette.surface)

                VoiceRecordingSection(voice: voice)

                Section {
                    if store.categories.isEmpty {
                        Text("Create a category in My Words first.")
                            .foregroundStyle(Theme.Palette.textSecondary)
                    } else {
                        Picker("Category", selection: $categoryID) {
                            ForEach(store.categories) { category in
                                Text(category.name).tag(Optional(category.id))
                            }
                        }
                    }
                } header: {
                    Text("Category")
                }
                .listRowBackground(Theme.Palette.surface)

                Section {
                    ForEach(store.contexts) { context in
                        Toggle(isOn: binding(for: context.id)) {
                            Label(context.name, systemImage: context.symbol)
                        }
                    }
                } header: {
                    Text("Show in")
                } footer: {
                    Text("Leave all off to show this phrase in every context.")
                }
                .listRowBackground(Theme.Palette.surface)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Palette.background)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(original == nil ? "New Phrase" : "Edit Phrase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
            .onAppear {
                voice.configure(original: original?.voiceFile)
                if categoryID == nil {
                    categoryID = store.categories.first?.id
                }
            }
            .onDisappear {
                // Throws away a take that was never saved. After a save this does nothing.
                voice.discard()
            }
        }
    }

    private func binding(for id: UUID) -> Binding<Bool> {
        Binding(
            get: { contextIDs.contains(id) },
            set: { isOn in
                if isOn {
                    contextIDs.insert(id)
                } else {
                    contextIDs.remove(id)
                }
            }
        )
    }

    private func save() {
        guard let categoryID, !cleanText.isEmpty else { return }

        voice.stopRecording()
        let voiceFile = voice.commit()

        if var updated = original {
            updated.text = cleanText
            updated.categoryID = categoryID
            updated.contextIDs = contextIDs
            updated.voiceFile = voiceFile
            store.updatePhrase(updated)
        } else {
            store.addPhrase(text: cleanText, categoryID: categoryID, contextIDs: contextIDs, voiceFile: voiceFile)
        }
        Haptics.success()
        dismiss()
    }
}
