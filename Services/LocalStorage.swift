//
//  LocalStorage.swift
//  Silent Voice
//
//  Created by Adityasinh on 30/09/26.
//
import Foundation

/// Reads and writes AppData as a single JSON file in Application Support.
/// Fully offline, no dependencies.
struct LocalStorage {
    private let fileURL: URL

    init(filename: String = "silentvoice.json") {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        fileURL = base.appendingPathComponent(filename)
    }

    /// Returns nil if there is no saved file, or if it can't be decoded.
    /// A file that can't be decoded is moved aside (not deleted) so the user's data isn't silently lost.
    func load() -> AppData? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        do {
            return try JSONDecoder().decode(AppData.self, from: data)
        } catch {
            let backup = fileURL.appendingPathExtension("corrupt")
            try? FileManager.default.removeItem(at: backup)
            try? FileManager.default.moveItem(at: fileURL, to: backup)
            return nil
        }
    }

    func save(_ appData: AppData) throws {
        let data = try JSONEncoder().encode(appData)
        try data.write(to: fileURL, options: [.atomic])
    }
}
