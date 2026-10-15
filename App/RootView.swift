//
//  RootView.swift
//  Silent Voice
//
//  Created by Adityasinh on 30/09/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var showSaveError = false

    var body: some View {
        TabView {
            QuickSpeakView()
                .tabItem { Label("Speak", systemImage: "bubble.left.fill") }

            MyWordsView()
                .tabItem { Label("My Words", systemImage: "text.book.closed.fill") }

            ContextsView()
                .tabItem { Label("Contexts", systemImage: "square.grid.2x2.fill") }

            PartnersView()
                .tabItem { Label("Partners", systemImage: "person.2.fill") }
        }
        // Shown once, on the first launch only.
        .fullScreenCover(isPresented: Binding(
            get: { !hasSeenWelcome },
            set: { if !$0 { hasSeenWelcome = true } }
        )) {
            WelcomeView {
                hasSeenWelcome = true
            }
        }
        // If saving ever fails, say so instead of silently losing changes.
        .onChange(of: store.lastSaveError) { newValue in
            showSaveError = newValue != nil
        }
        .alert("Couldn't save your changes", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your latest change may not be saved. Check that your device has free storage, then try again.")
        }
    }
}
