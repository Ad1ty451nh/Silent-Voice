//
//  CategoryPhrasesView.swift
//  Silent Voice
//
//  Created by Adityasinh on 01/10/26.
//

import SwiftUI

struct CategoryPhrasesView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let categoryID: UUID

    @State private var showNewPhrase = false
    @State private var showEditCategory = false
    @State private var showDeleteDialog = false

    private var category: PhraseCategory? {
        store.categories.first { $0.id == categoryID }
    }

    private var phrases: [Phrase] {
        store.phrases(in: categoryID)
    }

    var body: some View {
        ScrollView {
            if phrases.isEmpty {
                EmptyStateView(
                    symbol: category?.symbol ?? "text.bubble",
                    title: "Nothing here yet",
                    message: "Add the things you'd like to be able to say.",
                    actionTitle: "Add a phrase"
                ) {
                    showNewPhrase = true
                }
                .padding(.top, Theme.Spacing.xl)
            } else {
                PhraseList(phrases: phrases)
                    .padding(Theme.Spacing.m)
            }
        }
        .background(Theme.Palette.background)
        .navigationTitle(category?.name ?? "")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showNewPhrase = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add phrase")

                Menu {
                    Button {
                        showEditCategory = true
                    } label: {
                        Label("Edit Category", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteDialog = true
                    } label: {
                        Label("Delete Category", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("Category options")
            }
        }
        .sheet(isPresented: $showNewPhrase) {
            PhraseEditorView(categoryID: categoryID)
        }
        .sheet(isPresented: $showEditCategory) {
            if let category {
                NameSymbolEditor(
                    title: "Edit Category",
                    namePlaceholder: "Category name",
                    symbols: SymbolLibrary.categories,
                    name: category.name,
                    symbol: category.symbol
                ) { name, symbol in
                    var updated = category
                    updated.name = name
                    updated.symbol = symbol
                    store.updateCategory(updated)
                }
            }
        }
        .confirmationDialog(
            "Delete \(category?.name ?? "this category")?",
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) {
            Button("Delete Category", role: .destructive) {
                store.deleteCategory(id: categoryID)
                Haptics.warning()
                dismiss()
            }
        } message: {
            Text(phrases.isEmpty
                 ? "This can't be undone."
                 : "This also removes its \(phrases.count) phrase\(phrases.count == 1 ? "" : "s"). This can't be undone.")
        }
    }
}
