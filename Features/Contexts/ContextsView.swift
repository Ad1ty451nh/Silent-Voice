//
//  ContextsView.swift
//  Silent Voice
//
//  Created by Adityasinh on 01/10/26.
//

import SwiftUI

struct ContextsView: View {
    @EnvironmentObject private var store: AppStore

    @State private var showNewContext = false
    @State private var showNewPhrase = false
    @State private var showDeleteDialog = false

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: Theme.Spacing.m)]

    /// Favorites first, then the rest in their saved order.
    private var phrases: [Phrase] {
        let all = store.phrasesForSelectedContext()
        return all.filter(\.isFavorite) + all.filter { !$0.isFavorite }
    }

    private var sectionTitle: String {
        if let context = store.selectedContext {
            return "Phrases for \(context.name)"
        }
        return "All phrases"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                        Text("Where are you?")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Theme.Palette.textPrimary)
                            .accessibilityAddTraits(.isHeader)

                        LazyVGrid(columns: columns, spacing: Theme.Spacing.m) {
                            Button {
                                select(nil)
                            } label: {
                                TileCard(
                                    symbol: "square.grid.2x2.fill",
                                    title: "Everything",
                                    subtitle: countText(store.phrases.count),
                                    isSelected: store.selectedContext == nil
                                )
                            }
                            .buttonStyle(PhraseCardPressStyle())

                            ForEach(store.contexts) { context in
                                Button {
                                    select(context.id)
                                } label: {
                                    TileCard(
                                        symbol: context.symbol,
                                        title: context.name,
                                        subtitle: countText(count(for: context)),
                                        isSelected: store.selectedContext?.id == context.id
                                    )
                                }
                                .buttonStyle(PhraseCardPressStyle())
                            }

                            Button {
                                showNewContext = true
                            } label: {
                                TileCard(
                                    symbol: "plus",
                                    title: "New Context",
                                    tint: Theme.Palette.textSecondary,
                                    isDashed: true
                                )
                            }
                            .buttonStyle(PhraseCardPressStyle())
                        }
                    }

                    VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                        Text(sectionTitle)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Theme.Palette.textPrimary)
                            .accessibilityAddTraits(.isHeader)

                        if phrases.isEmpty {
                            EmptyStateView(
                                symbol: "text.bubble",
                                title: "Nothing here yet",
                                message: "Add phrases and choose where they should show up.",
                                actionTitle: "Add a phrase"
                            ) {
                                showNewPhrase = true
                            }
                        } else {
                            PhraseList(phrases: phrases)
                        }
                    }
                }
                .padding(Theme.Spacing.m)
            }
            .background(Theme.Palette.background)
            .navigationTitle("Contexts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showNewPhrase = true
                        } label: {
                            Label("New Phrase", systemImage: "text.bubble")
                        }

                        Button {
                            showNewContext = true
                        } label: {
                            Label("New Context", systemImage: "plus.circle")
                        }

                        if let selected = store.selectedContext {
                            Button(role: .destructive) {
                                showDeleteDialog = true
                            } label: {
                                Label("Delete \(selected.name)", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Context options")
                }
            }
            .sheet(isPresented: $showNewContext) {
                NameSymbolEditor(
                    title: "New Context",
                    namePlaceholder: "e.g. Grandma's house",
                    symbols: SymbolLibrary.contexts
                ) { name, symbol in
                    if let created = store.addContext(name: name, symbol: symbol) {
                        store.selectContext(created.id)
                    }
                }
            }
            .sheet(isPresented: $showNewPhrase) {
                PhraseEditorView(categoryID: nil, contextID: store.selectedContext?.id)
            }
            .confirmationDialog(
                "Delete this context?",
                isPresented: $showDeleteDialog,
                titleVisibility: .visible
            ) {
                if let selected = store.selectedContext {
                    Button("Delete \(selected.name)", role: .destructive) {
                        store.deleteContext(id: selected.id)
                        Haptics.warning()
                    }
                }
            } message: {
                Text("Your phrases are kept. They just won't be linked to this context anymore.")
            }
        }
    }

    private func select(_ id: UUID?) {
        Haptics.soft()
        store.selectContext(id)
    }

    /// Phrases that would show in this context (phrases with no contexts show everywhere).
    private func count(for context: CommunicationContext) -> Int {
        store.phrases.filter { $0.contextIDs.isEmpty || $0.contextIDs.contains(context.id) }.count
    }

    private func countText(_ count: Int) -> String {
        count == 1 ? "1 phrase" : "\(count) phrases"
    }
}
