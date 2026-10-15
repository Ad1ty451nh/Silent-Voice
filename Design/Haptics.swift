//
//  Haptics.swift
//  Silent Voice
//
//  Created by Adityasinh on 30/09/26.
//
import UIKit

/// Simple haptics wrapper. UIKit feedback generators are enough here;
/// we only bring in Core Haptics if a feature actually needs custom patterns.
@MainActor
enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func soft() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
