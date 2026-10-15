//
//  SpeechSettingsView.swift
//  Silent Voice
//
//  Created by Adityasinh on 03/10/26.
//

import SwiftUI
import AVFoundation

/// Speaking speed, voice choice and Personal Voice access.
struct SpeechSettingsView: View {
    @EnvironmentObject private var speech: SpeechService
    @Environment(\.dismiss) private var dismiss

    private var speedPercent: Int {
        Int((speech.rate / AVSpeechUtteranceMaximumSpeechRate * 100).rounded())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                        Slider(value: $speech.rate, in: 0.25...0.6)
                            .accessibilityLabel("Speaking speed")
                            .accessibilityValue("\(speedPercent) percent")

                        HStack {
                            Text("Slower")
                            Spacer()
                            Text("Faster")
                        }
                        .font(.footnote)
                        .foregroundStyle(Theme.Palette.textSecondary)
                        .accessibilityHidden(true)
                    }
                    .padding(.vertical, Theme.Spacing.xs)

                    Button {
                        Haptics.tap()
                        speech.speak("Hello, this is how I sound.")
                    } label: {
                        Label("Try it", systemImage: "speaker.wave.2.fill")
                    }
                } header: {
                    Text("Speaking speed")
                }
                .listRowBackground(Theme.Palette.surface)

                Section {
                    Picker("Voice", selection: $speech.voiceIdentifier) {
                        Text("System default").tag(String?.none)
                        ForEach(speech.availableVoices(), id: \.identifier) { voice in
                            Text(label(for: voice)).tag(Optional(voice.identifier))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Voice")
                } footer: {
                    Text("Better voices can be downloaded in Settings → Accessibility → Spoken Content → Voices.")
                }
                .listRowBackground(Theme.Palette.surface)

                if #available(iOS 17.0, *) {
                    personalVoiceSection
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Palette.background)
            .navigationTitle("Voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        speech.stop()
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Personal Voice (iOS 17 and later)

    @available(iOS 17.0, *)
    private var personalVoiceSection: some View {
        Section {
            if speech.personalVoiceAllowed {
                Label("Personal Voice is allowed", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Theme.Palette.success)
            } else {
                Button {
                    Task { await speech.requestPersonalVoice() }
                } label: {
                    Label("Allow Personal Voice", systemImage: "person.wave.2.fill")
                }
            }
        } header: {
            Text("Personal Voice")
        } footer: {
            Text("If you've made a Personal Voice in Settings → Accessibility → Personal Voice, allow it here and it will appear in the voice list above. Silent Voice never records or copies it.")
        }
        .listRowBackground(Theme.Palette.surface)
    }

    // MARK: - Helpers

    private func label(for voice: AVSpeechSynthesisVoice) -> String {
        if speech.isPersonalVoice(voice) {
            return "\(voice.name) (Personal Voice)"
        }
        switch voice.quality {
        case .premium: return "\(voice.name) (Premium)"
        case .enhanced: return "\(voice.name) (Enhanced)"
        default: return voice.name
        }
    }
}
