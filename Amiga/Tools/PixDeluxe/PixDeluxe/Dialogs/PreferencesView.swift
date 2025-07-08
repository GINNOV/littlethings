//
//  PreferencesView.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/8/25.
//

import SwiftUI

struct PreferencesView: View {
    @StateObject private var settings = Settings()

    var body: some View {
        // AI_REVIEW: The layout has been adjusted to reduce padding and improve alignment.
        HStack(alignment: .center, spacing: 20) {
            // AI_REVIEW: The view now uses the custom "gear1" image from your asset catalog
            // instead of the SF Symbol.
            Image("gear1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.5))
                .frame(width: 120)

            Form {
                Text("On Application Launch")
                    .font(.headline)
                    .padding(.bottom, 5)

                Picker("Action:", selection: $settings.launchAction) {
                    ForEach(LaunchAction.allCases) { action in
                        Text(action.rawValue).tag(action)
                    }
                }
                .pickerStyle(.radioGroup)
            }
            .padding(.top, 10) // Reduced top padding for the form
        }
        .padding()
        .frame(width: 480, height: 180) // Adjusted frame for a more compact view
    }
}
