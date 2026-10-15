//
//  TypeToSpeakBar.swift
//  Silent Voice
//
//  Created by Adityasinh on 01/10/26.
//

import SwiftUI

/// Free-text speaking: type anything, tap the speaker (or press return) to say it.
/// Typed text can be saved to My Words in one tap. A Voice button opens speech settings.
struct TypeToSpeakBar: View {
    @EnvironmentObject private var speech: SpeechService
    @State private var text = ""
    @State private var showSave = false
    @State private var showVoice = false

    private var cleanText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSpeak: Bool {
        !cleanText.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            HStack(spacing: Theme.Spacing.m) {
                HStack(spacing: Theme.Spacing.s) {
                    TextField("Type to say out loud", text: $text)
                        .font(.title3)
                        .foregroundStyle(Theme.Palette.textPrimary)
                        .submitLabel(.send)
                        .onSubmit(speakTyped)

                    if !text.isEmpty {
                        Button {
                            text = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Theme.Palette.textSecondary)
                                .frame(minWidth: 44, minHeight: 44)
                        }
                        .accessibilityLabel("Clear text")
                    }
                }
                .padding(.horizontal, Theme.Spacing.m)
                .frame(minHeight: Theme.minTouchTarget)
                .background(Theme.Palette.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.button))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.button)
                        .stroke(Theme.Palette.fieldBorder, lineWidth: 1.5)
                )

                Button {
                    if speech.isSpeaking {
                        speech.stop()
                    } else {
                        speakTyped()
                    }
                } label: {
                    Image(systemName: speech.isSpeaking ? "stop.fill" : "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: Theme.minTouchTarget, height: Theme.minTouchTarget)
                        .background(speech.isSpeaking ? Theme.Palette.danger : Theme.Palette.primary, in: Circle())
                }
                .disabled(!canSpeak && !speech.isSpeaking)
                .opacity(!canSpeak && !speech.isSpeaking ? 0.4 : 1)
                .accessibilityLabel(speech.isSpeaking ? "Stop speaking" : "Speak typed text")
            }

            HStack(spacing: Theme.Spacing.s) {
                if canSpeak {
                    Button {
                        Haptics.soft()
                        showSave = true
                    } label: {
                        pill("Save to My Words", symbol: "bookmark.fill")
                    }
                    .accessibilityHint("Saves what you typed as a phrase you can use again")
                    .sheet(isPresented: $showSave) {
                        PhraseEditorView(categoryID: nil, text: cleanText)
                    }
                }

                Button {
                    Haptics.soft()
                    showVoice = true
                } label: {
                    pill("Voice", symbol: "slider.horizontal.3")
                }
                .accessibilityHint("Change speaking speed and voice")
                .sheet(isPresented: $showVoice) {
                    SpeechSettingsView()
                }
            }
        }
    }

    private func pill(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.Palette.primary)
            .padding(.horizontal, Theme.Spacing.m)
            .frame(minHeight: 44)
            .background(Theme.Palette.surfaceElevated, in: Capsule())
    }

    private func speakTyped() {
        guard canSpeak else { return }
        Haptics.tap()
        speech.speak(text)
    }
}
