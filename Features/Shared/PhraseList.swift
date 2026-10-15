//
//  PhraseList.swift
//  Silent Voice
//
//  Created by Adityasinh on 01/10/26.
//

import SwiftUI

/// Speak / favorite / edit / delete list for any set of phrases.
/// Used by category pages, Favorites and Contexts so behavior is identical everywhere.
struct PhraseList: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var speech: SpeechService

    let phrases: [Phrase]

    @State private var editing: Phrase?
    @State private var pendingDelete: Phrase?
    @State private var showDeleteDialog = false

    var body: some View {
        LazyVStack(spacing: Theme.Spacing.s) {
            ForEach(phrases) { phrase in
                SentenceCard(
                    phrase: phrase,
                    onSpeak: {
                        Haptics.tap()
                        // Plays the person's own recording if the phrase has one, otherwise the system voice.
                        speech.say(phrase.text, recording: phrase.voiceFile)
                    },
                    onToggleFavorite: {
                        Haptics.soft()
                        store.toggleFavorite(id: phrase.id)
                    },
                    onEdit: {
                        editing = phrase
                    },
                    onDelete: {
                        pendingDelete = phrase
                        showDeleteDialog = true
                    }
                )
            }
        }
        .sheet(item: $editing) { phrase in
            PhraseEditorView(phrase: phrase)
        }
        .confirmationDialog(
            "Delete this phrase?",
            isPresented: $showDeleteDialog,
            titleVisibility: .visible,
            presenting: pendingDelete
        ) { phrase in
            Button("Delete", role: .destructive) {
                store.deletePhrase(id: phrase.id)
                Haptics.warning()
            }
        } message: { phrase in
            Text("“\(phrase.text)” will be removed from My Words.")
        }
    }
}
