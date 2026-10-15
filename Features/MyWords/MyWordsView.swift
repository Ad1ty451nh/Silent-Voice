//
//  MyWordsView.swift
//  Silent Voice
//
//  Created by Adityasinh on 01/10/26.
//

import SwiftUI

enum MyWordsRoute: Hashable {
    case favorites
    case category(UUID)
}

struct MyWordsView: View {
    @EnvironmentObject private var store: AppStore

    @State private var showNewCategory = false
    @State private var showNewPhrase = false

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: Theme.Spacing.m)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: Theme.Spacing.m) {
                    NavigationLink(value: MyWordsRoute.favorites) {
                        TileCard(
                            symbol: "star.fill",
                            title: "Favorites",
                            subtitle: countText(store.favorites.count),
                            tint: Theme.Palette.warning
                        )
                    }
                    .buttonStyle(PhraseCardPressStyle())

                    ForEach(store.categories) { category in
                        NavigationLink(value: MyWordsRoute.category(category.id)) {
                            TileCard(
                                symbol: category.symbol,
                                title: category.name,
                                subtitle: countText(store.phrases(in: category.id).count)
                            )
                        }
                        .buttonStyle(PhraseCardPressStyle())
                    }

                    Button {
                        showNewCategory = true
                    } label: {
                        TileCard(
                            symbol: "plus",
                            title: "New Category",
                            tint: Theme.Palette.textSecondary,
                            isDashed: true
                        )
                    }
                    .buttonStyle(PhraseCardPressStyle())
                }
                .padding(Theme.Spacing.m)
            }
            .background(Theme.Palette.background)
            .navigationTitle("My Words")
            .navigationDestination(for: MyWordsRoute.self) { route in
                switch route {
                case .favorites:
                    FavoritesView()
                case .category(let id):
                    CategoryPhrasesView(categoryID: id)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showNewPhrase = true
                        } label: {
                            Label("New Phrase", systemImage: "text.bubble")
                        }
                        .disabled(store.categories.isEmpty)

                        Button {
                            showNewCategory = true
                        } label: {
                            Label("New Category", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add")
                }
            }
            .sheet(isPresented: $showNewCategory) {
                NameSymbolEditor(
                    title: "New Category",
                    namePlaceholder: "e.g. School stuff",
                    symbols: SymbolLibrary.categories
                ) { name, symbol in
                    _ = store.addCategory(name: name, symbol: symbol)
                }
            }
            .sheet(isPresented: $showNewPhrase) {
                PhraseEditorView(categoryID: nil)
            }
        }
    }

    private func countText(_ count: Int) -> String {
        count == 1 ? "1 phrase" : "\(count) phrases"
    }
}

struct FavoritesView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ScrollView {
            if store.favorites.isEmpty {
                EmptyStateView(
                    symbol: "star",
                    title: "No favorites yet",
                    message: "Tap the star on any phrase to keep it close."
                )
                .padding(.top, Theme.Spacing.xl)
            } else {
                PhraseList(phrases: store.favorites)
                    .padding(Theme.Spacing.m)
            }
        }
        .background(Theme.Palette.background)
        .navigationTitle("Favorites")
    }
}
