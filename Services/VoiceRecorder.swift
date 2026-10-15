//
//  VoiceRecorder.swift
//  Silent Voice
//
//  Created by Adityasinh on 03/10/26.
//

import AVFoundation
import Combine

/// File helpers for voice recordings. Everything stays on the device, nothing is uploaded.
enum RecordingFiles {
    static var directory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent("Recordings", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    static func newFilename() -> String {
        UUID().uuidString + ".m4a"
    }

    static func url(for filename: String) -> URL {
        directory.appendingPathComponent(filename)
    }

    static func delete(_ filename: String?) {
        guard let filename else { return }
        try? FileManager.default.removeItem(at: url(for: filename))
    }
}

/// Records a short voice clip: a parent, a friend, or the person themselves.
/// A take is only a draft until `commit()`. `discard()` throws away anything unsaved.
@MainActor
final class VoiceRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    static let maxDuration: TimeInterval = 10
    private static let minDuration: TimeInterval = 0.4

    /// The current draft (or the saved recording if the person hasn't changed it).
    @Published private(set) var filename: String?
    @Published private(set) var isRecording = false
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var message: String?
    @Published private(set) var permissionDenied = false

    private var original: String?
    private var configured = false
    private var recorder: AVAudioRecorder?
    private var recordingName: String?
    private var ticker: Task<Void, Never>?
    private var isStarting = false

    override init() {
        super.init()
    }

    /// Call once with the recording the item already has (nil for a new item).
    func configure(original: String?) {
        guard !configured else { return }
        configured = true
        self.original = original
        filename = original
    }

    // MARK: - Recording

    func toggle() {
        if isRecording {
            stopRecording()
        } else if !isStarting {
            isStarting = true
            Task {
                await startRecording()
                isStarting = false
            }
        }
    }

    func stopRecording() {
        guard let recorder else { return }
        recorder.stop()
        finishRecording()
    }

    private func startRecording() async {
        message = nil

        guard await Self.requestPermission() else {
            permissionDenied = true
            message = "Microphone access is off. Turn it on in Settings to record a voice."
            return
        }
        permissionDenied = false

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            let name = RecordingFiles.newFilename()
            let newRecorder = try AVAudioRecorder(url: RecordingFiles.url(for: name), settings: settings)
            newRecorder.delegate = self

            guard newRecorder.record(forDuration: Self.maxDuration) else {
                RecordingFiles.delete(name)
                message = "Couldn't start recording. Please try again."
                return
            }

            recorder = newRecorder
            recordingName = name
            elapsed = 0
            isRecording = true
            startTicker()
        } catch {
            message = "Couldn't start recording. Please try again."
        }
    }

    /// Safe to call more than once (manual stop and the 10 second limit both end up here).
    private func finishRecording() {
        guard let name = recordingName else { return }

        ticker?.cancel()
        ticker = nil
        recorder = nil
        recordingName = nil
        isRecording = false

        let url = RecordingFiles.url(for: name)
        let duration = (try? AVAudioPlayer(contentsOf: url))?.duration ?? 0
        guard duration >= Self.minDuration else {
            RecordingFiles.delete(name)
            message = "That was too short. Tap Record, say it, then tap Stop."
            return
        }

        // Replace an earlier unsaved take. The saved original is only removed in commit().
        if let previous = filename, previous != original {
            RecordingFiles.delete(previous)
        }
        filename = name
        message = nil
    }

    // MARK: - Draft handling

    /// Removes the recording from the draft. A saved file is only deleted when the editor saves.
    func removeRecording() {
        if let current = filename, current != original {
            RecordingFiles.delete(current)
        }
        filename = nil
        message = nil
    }

    /// Call when the editor saves. Returns the file name to store (nil = no recording).
    func commit() -> String? {
        if let original, original != filename {
            RecordingFiles.delete(original)
        }
        original = filename
        return filename
    }

    /// Call when the editor closes. Deletes any take that was never saved.
    func discard() {
        ticker?.cancel()
        ticker = nil

        if isRecording {
            recorder?.stop()
            recorder = nil
            isRecording = false
            RecordingFiles.delete(recordingName)
            recordingName = nil
        }

        if let current = filename, current != original {
            RecordingFiles.delete(current)
            filename = original
        }
    }

    // MARK: - Helpers

    private var settings: [String: Any] {
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 22_050.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }

    private func startTicker() {
        ticker?.cancel()
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000)
                guard let self, self.isRecording else { return }
                self.elapsed = self.recorder?.currentTime ?? self.elapsed
            }
        }
    }

    /// Kept nonisolated so the system's callback queue doesn't trip main-actor checks.
    nonisolated private static func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    // MARK: - AVAudioRecorderDelegate

    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in self.finishRecording() }
    }

    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Task { @MainActor in self.finishRecording() }
    }
}
