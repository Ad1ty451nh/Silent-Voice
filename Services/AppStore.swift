//
//  AppStore.swift
//  Silent Voice
//
//  Created by Adityasinh on 30/09/26.
//

import SwiftUI

/// Single source of truth for everything the user owns.
/// Every mutation goes through `mutate`, which saves immediately.
@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var data: AppData
    @Published private(set) var lastSaveError: String? = nil

    private let storage: LocalStorage

    init(storage: LocalStorage = LocalStorage()) {
        self.storage = storage
        if let loaded = storage.load() {
            data = loaded
        } else {
            data = AppData.seed()
            persist()
        }
    }

    // MARK: - Reads

    var quickSections: [QuickSection] { data.quickSections }
    var categories: [PhraseCategory] { data.categories }
    var contexts: [CommunicationContext] { data.contexts }
    var phrases: [Phrase] { data.phrases }
    var favorites: [Phrase] { data.phrases.filter(\.isFavorite) }

    var selectedContext: CommunicationContext? {
        data.contexts.first { $0.id == data.selectedContextID }
    }

    func phrases(in categoryID: UUID) -> [Phrase] {
        data.phrases.filter { $0.categoryID == categoryID }
    }

    /// Phrases for the active context. Phrases with no contexts assigned show everywhere.
    func phrasesForSelectedContext() -> [Phrase] {
        guard let id = data.selectedContextID else { return data.phrases }
        return data.phrases.filter { $0.contextIDs.isEmpty || $0.contextIDs.contains(id) }
    }

    // MARK: - Quick sections

    @discardableResult
    func addQuickSection(name: String) -> QuickSection? {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return nil }
        let section = QuickSection(name: clean, phrases: [])
        mutate { $0.quickSections.append(section) }
        return section
    }

    func renameQuickSection(id: UUID, name: String) {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        mutate { data in
            guard let i = data.quickSections.firstIndex(where: { $0.id == id }) else { return }
            data.quickSections[i].name = clean
        }
    }

    /// Deletes the section AND its phrases (and their voice recordings). The UI must confirm before calling this.
    func deleteQuickSection(id: UUID) {
        data.quickSections.first { $0.id == id }?.phrases.forEach { RecordingFiles.delete($0.voiceFile) }
        mutate { $0.quickSections.removeAll { $0.id == id } }
    }

    // MARK: - Quick phrases

    func addQuickPhrase(text: String, spokenText: String? = nil, tone: QuickTone = .neutral, sectionID: UUID, voiceFile: String? = nil) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        mutate { data in
            guard let i = data.quickSections.firstIndex(where: { $0.id == sectionID }) else { return }
            data.quickSections[i].phrases.append(
                QuickPhrase(text: clean, spokenText: spokenText, tone: tone, voiceFile: voiceFile)
            )
        }
    }

    func updateQuickPhrase(_ phrase: QuickPhrase) {
        mutate { data in
            for s in data.quickSections.indices {
                if let i = data.quickSections[s].phrases.firstIndex(where: { $0.id == phrase.id }) {
                    data.quickSections[s].phrases[i] = phrase
                    return
                }
            }
        }
    }

    func deleteQuickPhrase(id: UUID) {
        for section in data.quickSections {
            section.phrases.filter { $0.id == id }.forEach { RecordingFiles.delete($0.voiceFile) }
        }
        mutate { data in
            for s in data.quickSections.indices {
                data.quickSections[s].phrases.removeAll { $0.id == id }
            }
        }
    }

    func moveQuickPhrases(in sectionID: UUID, from source: IndexSet, to destination: Int) {
        mutate { data in
            guard let i = data.quickSections.firstIndex(where: { $0.id == sectionID }) else { return }
            data.quickSections[i].phrases.move(fromOffsets: source, toOffset: destination)
        }
    }

    // MARK: - Phrases

    func addPhrase(text: String, categoryID: UUID, contextIDs: Set<UUID> = [], voiceFile: String? = nil) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        mutate {
            $0.phrases.append(
                Phrase(text: clean, categoryID: categoryID, contextIDs: contextIDs, voiceFile: voiceFile)
            )
        }
    }

    func updatePhrase(_ phrase: Phrase) {
        mutate { data in
            guard let i = data.phrases.firstIndex(where: { $0.id == phrase.id }) else { return }
            data.phrases[i] = phrase
        }
    }

    func deletePhrase(id: UUID) {
        data.phrases.filter { $0.id == id }.forEach { RecordingFiles.delete($0.voiceFile) }
        mutate { $0.phrases.removeAll { $0.id == id } }
    }

    func toggleFavorite(id: UUID) {
        mutate { data in
            guard let i = data.phrases.firstIndex(where: { $0.id == id }) else { return }
            data.phrases[i].isFavorite.toggle()
        }
    }

    // MARK: - Categories

    @discardableResult
    func addCategory(name: String, symbol: String) -> PhraseCategory? {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return nil }
        let category = PhraseCategory(name: clean, symbol: symbol)
        mutate { $0.categories.append(category) }
        return category
    }

    func updateCategory(_ category: PhraseCategory) {
        mutate { data in
            guard let i = data.categories.firstIndex(where: { $0.id == category.id }) else { return }
            data.categories[i] = category
        }
    }

    /// Deletes the category AND its phrases (and their voice recordings). The UI must confirm before calling this.
    func deleteCategory(id: UUID) {
        data.phrases.filter { $0.categoryID == id }.forEach { RecordingFiles.delete($0.voiceFile) }
        mutate { data in
            data.categories.removeAll { $0.id == id }
            data.phrases.removeAll { $0.categoryID == id }
        }
    }

    // MARK: - Contexts

    func selectContext(_ id: UUID?) {
        mutate { $0.selectedContextID = id }
    }

    @discardableResult
    func addContext(name: String, symbol: String) -> CommunicationContext? {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return nil }
        let context = CommunicationContext(name: clean, symbol: symbol)
        mutate { $0.contexts.append(context) }
        return context
    }

    func deleteContext(id: UUID) {
        mutate { data in
            data.contexts.removeAll { $0.id == id }
            for i in data.phrases.indices {
                data.phrases[i].contextIDs.remove(id)
            }
            if data.selectedContextID == id { data.selectedContextID = nil }
        }
    }

    // MARK: - Persistence

    private func mutate(_ change: (inout AppData) -> Void) {
        change(&data)
        persist()
    }

    private func persist() {
        do {
            try storage.save(data)
            lastSaveError = nil
        } catch {
            lastSaveError = error.localizedDescription
        }
    }
}
