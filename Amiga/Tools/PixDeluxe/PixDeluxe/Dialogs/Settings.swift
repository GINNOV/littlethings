//
//  Settings.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/8/25.
//

import Foundation
import SwiftUI

/// An enumeration of possible actions the app can take on launch.
enum LaunchAction: String, CaseIterable, Identifiable {
    case doNothing = "Do Nothing"
    case openFileSelection = "Show Open Dialog"
    case openImageBrowser = "Open Image Browser"

    var id: String { self.rawValue }
}

/// An observable object to manage and persist application settings.
class Settings: ObservableObject {
    /// The user's selected action to perform when the application launches.
    /// This property is backed by UserDefaults, so the choice is saved across app launches.
    @AppStorage("launchAction") var launchAction: LaunchAction = .doNothing
}
