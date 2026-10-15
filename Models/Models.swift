//
//  Models.swift
//  Silent Voice
//
//  Created by Adityasinh on 30/09/26.
//
import Foundation

struct PhraseCategory: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var symbol: String
}

struct CommunicationContext: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var symbol: String
}

struct Phrase: Identifiable, Codable, Hashable {
    var id = UUID()
    var text: String
    var categoryID: UUID
    var isFavorite = false
    /// Contexts where this phrase should be surfaced. Empty = shown everywhere.
    var contextIDs: Set<UUID> = []
    /// File name of a voice recording made on this device. nil = use the system voice.
    var voiceFile: String? = nil
}
