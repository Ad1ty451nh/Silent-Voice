//
//  VoiceRecordingSection.swift
//  Silent Voice
//
//  Created by Adityasinh on 03/10/26.
//

import SwiftUI
import UIKit

/// "Recorded voice" block used inside the card editor and the phrase editor.
/// Optional: with no recording, the card uses Apple's system voice as before.
struct VoiceRecordingSection: View {
    @EnvironmentObject private var speech: SpeechService
    @ObservedObject var voice: VoiceRecorder
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            if voice.isRecording {
                recordingRows
            } else if voice.filename != nil {
                savedRows
            } else {
                recordButton
            }

            if let message = voice.message {
                messageRows(message)
            }
        } header: {
            Text("Recorded voice")
        } footer: {
            Text("Optional. Someone can record their own voice saying this, and the card will play it instead of the computer voice. Recordings stay on this device.")
        }
        .listRowBackground(Theme.Palette.surface)
    }

    // MARK: - Rows

    private var recordButton: some View {
        Button {
            startTapped()
        } label: {
            Label("Record a voice", systemImage: "mic.fill")
        }
        .accessibilityHint("Records a short message, up to 10 seconds")
    }

    @ViewBuilder
    private var recordingRows: some View {
        Button {
            Haptics.tap()
            voice.stopRecording()
        } label: {
            Label("Stop recording", systemImage: "stop.circle.fill")
                .foregroundStyle(Theme.Palette.danger)
        }

        Text("Recording… \(Int(voice.elapsed)) of \(Int(VoiceRecorder.maxDuration)) seconds")
            .font(.subheadline)
            .foregroundStyle(Theme.Palette.textSecondary)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var savedRows: some View {
        Button {
            playTapped()
        } label: {
            Label(
                speech.isSpeaking ? "Stop" : "Play recording",
                systemImage: speech.isSpeaking ? "stop.fill" : "play.fill"
            )
        }

        Button {
            startTapped()
        } label: {
            Label("Record again", systemImage: "mic.fill")
        }

        Button(role: .destructive) {
            Haptics.warning()
            speech.stop()
            voice.removeRecording()
        } label: {
            Label("Remove recording", systemImage: "trash")
        }
    }

    @ViewBuilder
    private func messageRows(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(Theme.Palette.danger)

        if voice.permissionDenied {
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            } label: {
                Label("Open Settings", systemImage: "gearshape")
            }
        }
    }

    // MARK: - Actions

    private func startTapped() {
        Haptics.tap()
        speech.stop()
        voice.toggle()
    }

    private func playTapped() {
        if speech.isSpeaking {
            speech.stop()
        } else if let file = voice.filename {
            Haptics.tap()
            speech.playRecording(file)
        }
    }
}
