//
//  SpeechService.swift
//  Silent Voice
//
//  Created by Adityasinh on 30/09/26.
//

import AVFoundation
import Combine

/// Thin wrapper around Apple's AVSpeechSynthesizer. No custom voices.
/// It also plays voice recordings that people make themselves (see VoiceRecorder).
/// Speed and voice choice are saved on the device.
@MainActor
final class SpeechService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    private enum Key {
        static let rate = "speech.rate"
        static let voice = "speech.voice"
    }

    @Published private(set) var isSpeaking = false
    @Published var rate: Float {
        didSet { UserDefaults.standard.set(rate, forKey: Key.rate) }
    }
    /// nil = the system's default voice.
    @Published var voiceIdentifier: String? {
        didSet { UserDefaults.standard.set(voiceIdentifier, forKey: Key.voice) }
    }
    @Published private(set) var personalVoiceAllowed: Bool

    private let synthesizer = AVSpeechSynthesizer()
    private var player: AVAudioPlayer?

    override init() {
        let defaults = UserDefaults.standard
        rate = defaults.object(forKey: Key.rate) == nil
            ? AVSpeechUtteranceDefaultSpeechRate
            : defaults.float(forKey: Key.rate)
        voiceIdentifier = defaults.string(forKey: Key.voice)

        if #available(iOS 17.0, *) {
            personalVoiceAllowed = AVSpeechSynthesizer.personalVoiceAuthorizationStatus == .authorized
        } else {
            personalVoiceAllowed = false
        }

        super.init()
        synthesizer.delegate = self
        // .playback so speech is audible even with the silent switch on.
        // For an AAC app, a muted voice is a broken app.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
    }

    // MARK: - Speaking

    /// Speaks immediately, cutting off anything already being spoken.
    func speak(_ text: String) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }

        activatePlaybackSession()
        stopPlayer()

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: clean)
        utterance.rate = rate
        if let id = voiceIdentifier, let voice = AVSpeechSynthesisVoice(identifier: id) {
            utterance.voice = voice
        }
        synthesizer.speak(utterance)
    }

    /// Plays the person's own recording if there is one (and the file still exists).
    /// Otherwise speaks the text with the system voice.
    func say(_ text: String, recording: String?) {
        if let recording, playRecording(recording) { return }
        speak(text)
    }

    /// Plays a recording from this device. Returns false if it couldn't be played.
    @discardableResult
    func playRecording(_ filename: String) -> Bool {
        let url = RecordingFiles.url(for: filename)
        guard FileManager.default.fileExists(atPath: url.path) else { return false }

        stop()
        activatePlaybackSession()

        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            guard newPlayer.play() else { return false }
            player = newPlayer
            isSpeaking = true
            return true
        } catch {
            return false
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        if player != nil {
            stopPlayer()
            isSpeaking = false
        }
    }

    // MARK: - Voices

    /// Installed voices for the person's language, best quality first.
    func availableVoices() -> [AVSpeechSynthesisVoice] {
        let code = String((Locale.preferredLanguages.first ?? "en").prefix(2))
        return AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix(code) }
            .sorted { lhs, rhs in
                if lhs.quality.rawValue != rhs.quality.rawValue {
                    return lhs.quality.rawValue > rhs.quality.rawValue
                }
                return lhs.name < rhs.name
            }
    }

    func isPersonalVoice(_ voice: AVSpeechSynthesisVoice) -> Bool {
        if #available(iOS 17.0, *) {
            return voice.voiceTraits.contains(.isPersonalVoice)
        }
        return false
    }

    /// Asks permission to use Personal Voices the person already created in Settings. iOS 17 and later.
    func requestPersonalVoice() async {
        guard #available(iOS 17.0, *) else { return }
        let status = await AVSpeechSynthesizer.requestPersonalVoiceAuthorization()
        personalVoiceAllowed = (status == .authorized)
    }

    // MARK: - Helpers

    /// Recording switches the audio session to record mode, so playback always puts it back.
    private func activatePlaybackSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
    }

    private func stopPlayer() {
        player?.stop()
        player = nil
    }

    // MARK: - AVSpeechSynthesizerDelegate

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = true }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = self.player?.isPlaying ?? false }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = self.player?.isPlaying ?? false }
    }

    // MARK: - AVAudioPlayerDelegate

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            if self.player?.isPlaying != true { self.player = nil }
            self.isSpeaking = self.synthesizer.isSpeaking
        }
    }
}
