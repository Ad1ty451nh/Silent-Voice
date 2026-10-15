//
//  NameSymbolEditor.swift
//  Silent Voice
//
//  Created by Adityasinh on 01/10/26.
//

import SwiftUI

/// Curated SF Symbols for categories and contexts. Kept small on purpose: fast to scan.
/// Both pickers share one list so an icon can't go missing from one of them.
enum SymbolLibrary {
    static let all: [String] = [
        // People and feelings
        "hand.raised.fill", "face.smiling", "person.2.fill", "person.3.fill",
        "heart.fill", "star.fill", "bell.fill", "phone.fill",

        // Places
        "house.fill", "graduationcap.fill", "cross.case.fill", "building.2.fill",
        "briefcase.fill", "cart.fill", "bag.fill", "bed.double.fill",

        // Getting around
        "bus.fill", "tram.fill", "car.fill", "airplane",
        "bicycle", "figure.walk",

        // Food and care
        "fork.knife", "cup.and.saucer.fill", "drop.fill", "pills.fill",
        "flame.fill", "gift.fill",

        // Fun and favorites
        "gamecontroller.fill", "tv.fill", "music.note", "headphones",
        "book.fill", "paintbrush.fill", "camera.fill", "sportscourt.fill",
        "pawprint.fill", "leaf.fill",

        // Time of day
        "sun.max.fill", "moon.fill"
    ]

    static let categories: [String] = all
    static let contexts: [String] = all

    /// Friendly names for VoiceOver where the raw symbol name reads badly.
    static let friendlyNames: [String: String] = [
        "gamecontroller": "Games",
        "cross.case": "Medical",
        "building.2": "Building",
        "bed.double": "Bed",
        "cup.and.saucer": "Cafe",
        "sportscourt": "Sports",
        "figure.walk": "Walking",
        "pawprint": "Pets",
        "graduationcap": "School",
        "person.3": "Group",
        "person.2": "People",
        "hand.raised": "Hand",
        "face.smiling": "Smile",
        "sun.max": "Sun",
        "music.note": "Music",
        "paintbrush": "Art",
        "fork.knife": "Food",
        "tv": "Television",
        "pills": "Medicine",
        "drop": "Water"
    ]
}

/// Shared "name + icon" editor for categories and contexts.
struct NameSymbolEditor: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let namePlaceholder: String
    let symbols: [String]
    let onSave: (String, String) -> Void

    @State private var name: String
    @State private var symbol: String
    /// The icon this item started with. Kept so a custom icon never disappears from the picker.
    private let initialSymbol: String

    init(
        title: String,
        namePlaceholder: String,
        symbols: [String],
        name: String = "",
        symbol: String? = nil,
        onSave: @escaping (String, String) -> Void
    ) {
        self.title = title
        self.namePlaceholder = namePlaceholder
        self.symbols = symbols
        self.onSave = onSave
        let start = symbol ?? symbols.first ?? "circle.fill"
        initialSymbol = start
        _name = State(initialValue: name)
        _symbol = State(initialValue: start)
    }

    private var cleanName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The list, plus the item's current icon first if it isn't already in the list.
    private var options: [String] {
        symbols.contains(initialSymbol) ? symbols : [initialSymbol] + symbols
    }

    private let gridColumns = [GridItem(.adaptive(minimum: 60), spacing: Theme.Spacing.s)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                        Text("Name")
                            .font(.headline)
                            .foregroundStyle(Theme.Palette.textPrimary)
                            .accessibilityAddTraits(.isHeader)

                        TextField(namePlaceholder, text: $name)
                            .font(.title3)
                            .foregroundStyle(Theme.Palette.textPrimary)
                            .padding(.horizontal, Theme.Spacing.m)
                            .frame(minHeight: Theme.minTouchTarget)
                            .background(Theme.Palette.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.button))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.button)
                                    .stroke(Theme.Palette.fieldBorder, lineWidth: 1.5)
                            )
                    }

                    VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                        Text("Icon")
                            .font(.headline)
                            .foregroundStyle(Theme.Palette.textPrimary)
                            .accessibilityAddTraits(.isHeader)

                        LazyVGrid(columns: gridColumns, spacing: Theme.Spacing.s) {
                            ForEach(options, id: \.self) { option in
                                Button {
                                    Haptics.soft()
                                    symbol = option
                                } label: {
                                    Image(systemName: option)
                                        .font(.title2)
                                        .foregroundStyle(symbol == option ? Color.white : Theme.Palette.primary)
                                        .frame(maxWidth: .infinity, minHeight: 60)
                                        .background(
                                            symbol == option ? Theme.Palette.primary : Theme.Palette.surfaceElevated,
                                            in: RoundedRectangle(cornerRadius: 14)
                                        )
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(spokenName(for: option))
                                .accessibilityAddTraits(symbol == option ? .isSelected : [])
                            }
                        }
                    }
                }
                .padding(Theme.Spacing.m)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.Palette.background)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(cleanName, symbol)
                        Haptics.success()
                        dismiss()
                    }
                    .disabled(cleanName.isEmpty)
                }
            }
        }
    }

    /// "fork.knife" becomes "Food" (or "fork knife" if there's no friendly name) so VoiceOver has something readable.
    private func spokenName(for symbolName: String) -> String {
        let base = symbolName.replacingOccurrences(of: ".fill", with: "")
        if let friendly = SymbolLibrary.friendlyNames[base] {
            return friendly
        }
        return base.replacingOccurrences(of: ".", with: " ")
    }
}
