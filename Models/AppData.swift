//
//  AppData.swift
//  Silent Voice
//
//  Created by Adityasinh on 30/09/26.
//

import Foundation

/// Everything the user owns, in one Codable blob.
struct AppData: Codable {
    var quickSections: [QuickSection]
    var categories: [PhraseCategory]
    var contexts: [CommunicationContext]
    var phrases: [Phrase]
    var selectedContextID: UUID?
}

extension AppData {
    /// First-launch starter content. Everything here is editable or deletable by the user.
    static func seed() -> AppData {
        let simpleWords = QuickSection(name: "Simple Words", phrases: [
            QuickPhrase(text: "Yes", tone: .yes),
            QuickPhrase(text: "No", tone: .no),
            QuickPhrase(text: "Maybe", tone: .maybe),
            QuickPhrase(text: "Wait", tone: .wait),
            QuickPhrase(text: "Help", tone: .help),
            QuickPhrase(text: "Stop", tone: .stop),
            QuickPhrase(text: "I don't know", tone: .neutral),
            QuickPhrase(text: "Give me a moment", tone: .neutral)
        ])

        let requests = QuickSection(name: "Requests", phrases: [
            QuickPhrase(text: "Food", spokenText: "I want food, please."),
            QuickPhrase(text: "Water", spokenText: "I want water, please."),
            QuickPhrase(text: "Bathroom", spokenText: "I need the bathroom."),
            QuickPhrase(text: "Comb", spokenText: "I need my comb.")
        ])

        let needs = PhraseCategory(name: "Needs", symbol: "hand.raised.fill")
        let feelings = PhraseCategory(name: "Feelings", symbol: "face.smiling")
        let people = PhraseCategory(name: "People", symbol: "person.2.fill")
        let food = PhraseCategory(name: "Food", symbol: "fork.knife")
        let activities = PhraseCategory(name: "Activities", symbol: "figure.walk")

        let home = CommunicationContext(name: "Home", symbol: "house.fill")
        let school = CommunicationContext(name: "School", symbol: "graduationcap.fill")
        let hospital = CommunicationContext(name: "Hospital", symbol: "cross.case.fill")
        let social = CommunicationContext(name: "Social", symbol: "person.3.fill")

        let phrases: [Phrase] = [
            Phrase(text: "I want to go outside.", categoryID: activities.id, contextIDs: [home.id]),
            Phrase(text: "I need some quiet.", categoryID: needs.id),
            Phrase(text: "I don't understand.", categoryID: needs.id),
            Phrase(text: "Please wait.", categoryID: needs.id),
            Phrase(text: "I'm uncomfortable.", categoryID: feelings.id, contextIDs: [hospital.id, home.id]),
            Phrase(text: "I'm in pain.", categoryID: feelings.id, contextIDs: [hospital.id]),
            Phrase(text: "I'm happy.", categoryID: feelings.id),
            Phrase(text: "I want to talk to my family.", categoryID: people.id, contextIDs: [home.id]),
            Phrase(text: "I'm thirsty.", categoryID: food.id, contextIDs: [home.id, school.id]),
            Phrase(text: "I need the bathroom.", categoryID: needs.id, contextIDs: [school.id, hospital.id]),
            Phrase(text: "Can I have a turn?", categoryID: activities.id, contextIDs: [school.id, social.id]),
            Phrase(text: "Nice to meet you.", categoryID: people.id, contextIDs: [social.id])
        ]

        return AppData(
            quickSections: [simpleWords, requests],
            categories: [needs, feelings, people, food, activities],
            contexts: [home, school, hospital, social],
            phrases: phrases,
            selectedContextID: home.id
        )
    }
}
