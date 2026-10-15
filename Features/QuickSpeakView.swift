//
//  QuickSpeakView.swift
//  Silent Voice
//
//  Created by Adityasinh on 30/09/26.
//

import SwiftUI

struct QuickSpeakView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var speech: SpeechService
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isEditing = false
    @State private var sheet: ActiveSheet?
    @State private var sectionToDelete: QuickSection?
    @State private var showDeleteSection = false

    /// One sheet at a time, driven by a single state value.
    private enum ActiveSheet: Identifiable {
        case newCard(sectionID: UUID)
        case editCard(QuickPhrase)
        case newSection
        case renameSection(QuickSection)
        case reorder(sectionID: UUID)

        var id: String {
            switch self {
            case .newCard(let sectionID): "newCard-\(sectionID)"
            case .editCard(let phrase): "editCard-\(phrase.id)"
            case .newSection: "newSection"
            case .renameSection(let section): "renameSection-\(section.id)"
            case .reorder(let sectionID): "reorder-\(sectionID)"
            }
        }
    }

    /// 3 columns on a normal iPhone. One column at accessibility text sizes so nothing clips.
    private var columns: [GridItem] {
        dynamicTypeSize.isAccessibilitySize
            ? [GridItem(.flexible())]
            : [GridItem(.adaptive(minimum: 100), spacing: Theme.Spacing.m)]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                    if !isEditing {
                        TypeToSpeakBar()
                    }

                    if store.quickSections.isEmpty {
                        EmptyStateView(
                            symbol: "bubble.left.and.bubble.right",
                            title: "Quick Speak is empty",
                            message: "Add a section, then fill it with the words you use most.",
                            actionTitle: "Add a section"
                        ) {
                            sheet = .newSection
                        }
                    } else {
                        ForEach(store.quickSections) { section in
                            sectionView(section)
                        }

                        if isEditing {
                            AddSectionButton {
                                sheet = .newSection
                            }
                        }
                    }
                }
                .padding(Theme.Spacing.m)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.Palette.background)
            .navigationTitle("Silent Voice")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(isEditing ? "Done" : "Edit") {
                        toggleEditing()
                    }
                }

                // The condition lives inside the item so this compiles cleanly on iOS 16.
                ToolbarItem(placement: .topBarTrailing) {
                    if speech.isSpeaking && !isEditing {
                        Button {
                            speech.stop()
                        } label: {
                            Label("Stop", systemImage: "speaker.slash.fill")
                        }
                        .accessibilityHint("Stops speaking")
                    }
                }
            }
            .sheet(item: $sheet) { item in
                switch item {
                case .newCard(let sectionID):
                    QuickPhraseEditorView(sectionID: sectionID)
                case .editCard(let phrase):
                    QuickPhraseEditorView(phrase: phrase)
                case .newSection:
                    QuickSectionNameEditor(title: "New Section", initialName: "") { name in
                        _ = store.addQuickSection(name: name)
                    }
                case .renameSection(let section):
                    QuickSectionNameEditor(title: "Rename Section", initialName: section.name) { name in
                        store.renameQuickSection(id: section.id, name: name)
                    }
                case .reorder(let sectionID):
                    QuickReorderView(sectionID: sectionID)
                }
            }
            .confirmationDialog(
                "Delete this section?",
                isPresented: $showDeleteSection,
                titleVisibility: .visible,
                presenting: sectionToDelete
            ) { section in
                Button("Delete \(section.name)", role: .destructive) {
                    store.deleteQuickSection(id: section.id)
                    Haptics.warning()
                }
            } message: { section in
                Text(section.phrases.isEmpty
                     ? "This can't be undone."
                     : "This also removes its \(section.phrases.count) card\(section.phrases.count == 1 ? "" : "s"). This can't be undone.")
            }
        }
    }

    // MARK: - Pieces

    private func sectionView(_ section: QuickSection) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            HStack {
                Text(section.name)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.Palette.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 0)

                if isEditing {
                    Menu {
                        Button {
                            sheet = .renameSection(section)
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }

                        Button {
                            sheet = .reorder(sectionID: section.id)
                        } label: {
                            Label("Reorder Cards", systemImage: "arrow.up.arrow.down")
                        }
                        .disabled(section.phrases.count < 2)

                        Button(role: .destructive) {
                            sectionToDelete = section
                            showDeleteSection = true
                        } label: {
                            Label("Delete Section", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .foregroundStyle(Theme.Palette.primary)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityLabel("Options for \(section.name)")
                }
            }

            if section.phrases.isEmpty && !isEditing {
                // Empty section outside edit mode: show a clear way to add the first card.
                EmptySectionPrompt(sectionName: section.name) {
                    Haptics.soft()
                    sheet = .newCard(sectionID: section.id)
                }
            } else {
                LazyVGrid(columns: columns, spacing: Theme.Spacing.m) {
                    ForEach(section.phrases) { phrase in
                        card(phrase)
                    }

                    if isEditing {
                        AddCardTile {
                            sheet = .newCard(sectionID: section.id)
                        }
                    }
                }
            }
        }
    }

    private func card(_ phrase: QuickPhrase) -> some View {
        PhraseCard(
            title: phrase.text,
            spoken: phrase.spoken,
            tone: phrase.tone,
            hint: cardHint(for: phrase)
        ) {
            if isEditing {
                Haptics.soft()
                sheet = .editCard(phrase)
            } else {
                Haptics.tap()
                // Plays the person's own recording if the card has one, otherwise the system voice.
                speech.say(phrase.spoken, recording: phrase.voiceFile)
            }
        }
        .overlay(alignment: .topLeading) {
            if phrase.voiceFile != nil {
                // Dark on the pastel card so the badge stays visible.
                Image(systemName: "waveform")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.Palette.primaryDark.opacity(0.8))
                    .padding(8)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .overlay(alignment: .topTrailing) {
            if isEditing {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.Palette.primaryDark)
                    .background(Circle().fill(Color.white))
                    .padding(6)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
    }

    private func cardHint(for phrase: QuickPhrase) -> String? {
        if isEditing { return "Edits this card" }
        return phrase.voiceFile == nil ? nil : "Plays a recorded voice"
    }

    private func toggleEditing() {
        Haptics.soft()
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            isEditing.toggle()
        }
    }
}

/// Shown in a section that has no cards yet (outside edit mode).
private struct EmptySectionPrompt: View {
    let sectionName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.s) {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Theme.Palette.primary)
                    .accessibilityHidden(true)

                Text("Add your first card")
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.textPrimary)

                Text("Tap here to add a word or phrase to this section.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(Theme.Spacing.l)
            .frame(maxWidth: .infinity, minHeight: Theme.quickButtonMinHeight + 40)
            .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .background(SoftDashedBackground(cornerRadius: Theme.Radius.card))
        }
        .buttonStyle(PhraseCardPressStyle())
        .accessibilityLabel("Add your first card to \(sectionName)")
        .accessibilityHint("Opens the card editor")
    }
}

/// Dashed "+" tile shown at the end of each section in edit mode.
private struct AddCardTile: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Theme.Palette.textSecondary)
                .frame(maxWidth: .infinity, minHeight: Theme.quickButtonMinHeight)
                .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
                .background(SoftDashedBackground(cornerRadius: Theme.Radius.button))
        }
        .buttonStyle(PhraseCardPressStyle())
        .accessibilityLabel("Add card")
    }
}

/// Full-width dashed button at the bottom of edit mode.
private struct AddSectionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Add Section", systemImage: "plus")
                .font(.headline)
                .foregroundStyle(Theme.Palette.textSecondary)
                .frame(maxWidth: .infinity, minHeight: Theme.minTouchTarget)
                .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.button))
                .background(SoftDashedBackground(cornerRadius: Theme.Radius.button))
        }
        .buttonStyle(PhraseCardPressStyle())
    }
}
