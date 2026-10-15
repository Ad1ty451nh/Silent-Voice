//
//  QuickEditSheets.swift
//  Silent Voice
//
//  Created by Adityasinh on 03/10/26.
//

import SwiftUI

/// Name-only editor for Quick Speak sections.
struct QuickSectionNameEditor: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let onSave: (String) -> Void

    @State private var name: String

    init(title: String, initialName: String, onSave: @escaping (String) -> Void) {
        self.title = title
        self.onSave = onSave
        _name = State(initialValue: initialName)
    }

    private var cleanName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("e.g. Greetings", text: $name)
                        .font(.title3)
                        .foregroundStyle(Theme.Palette.textPrimary)
                } header: {
                    Text("Section name")
                }
                .listRowBackground(Theme.Palette.surface)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Palette.background)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(cleanName)
                        Haptics.success()
                        dismiss()
                    }
                    .disabled(cleanName.isEmpty)
                }
            }
        }
    }
}

/// Drag to reorder the cards inside one Quick Speak section.
/// VoiceOver gets move up / move down actions automatically.
struct QuickReorderView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let sectionID: UUID

    private var section: QuickSection? {
        store.quickSections.first { $0.id == sectionID }
    }

    var body: some View {
        NavigationStack {
            List {
                if let section {
                    ForEach(section.phrases) { phrase in
                        HStack(spacing: Theme.Spacing.m) {
                            Circle()
                                .fill(phrase.tone.color)
                                .frame(width: 18, height: 18)
                                .accessibilityHidden(true)

                            Text(phrase.text)
                                .font(.title3)
                                .foregroundStyle(Theme.Palette.textPrimary)
                        }
                        .frame(minHeight: Theme.minTouchTarget, alignment: .leading)
                        .listRowBackground(Theme.Palette.surface)
                    }
                    .onMove { source, destination in
                        store.moveQuickPhrases(in: sectionID, from: source, to: destination)
                        Haptics.soft()
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .scrollContentBackground(.hidden)
            .background(Theme.Palette.background)
            .navigationTitle("Reorder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
