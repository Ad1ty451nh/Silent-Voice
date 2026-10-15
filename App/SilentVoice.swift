

import SwiftUI

@main
struct SilentVoiceApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var speech = SpeechService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(speech)
                .tint(Theme.Palette.primary)
                // The palette is designed for light backgrounds. Without this, system text turns
                // white in Dark Mode and disappears on the ivory background.
                .preferredColorScheme(.light)
        }
    }
}
