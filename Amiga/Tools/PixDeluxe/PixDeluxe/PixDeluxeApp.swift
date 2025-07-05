//
//  PixDeluxeApp.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/1/25.
//

import SwiftUI

@main
struct PixDeluxeApp: App {
    @StateObject private var viewModel = ContentViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        .commands {
            UtilitiesCommands(viewModel: viewModel)
        }
    }
}
