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
        HStack(alignment: .center, spacing: 1) {
            Image("gear1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
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
            .padding(.top, 5)
        }
        .padding()
        .frame(width: 480, height: 180)
    }
}
