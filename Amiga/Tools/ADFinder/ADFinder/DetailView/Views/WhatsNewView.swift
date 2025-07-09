//
//  WhatsNewView.swift
//  ADFinder
//
//  Created by Mario Esposito on 7/9/25.
//

import SwiftUI

struct WhatsNewView: View {
    @Binding var showWhatsNew: Bool
    @AppStorage("dontShowWhatsNew") private var dontShowWhatsNew = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What's New in This Release")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            VStack(alignment: .leading, spacing: 15) {
                FeatureView(
                    title: "Quick Look Support",
                    description: "You can use the spacebar on files and if you have the right plugin installed, Quick Look will show you the preview. Install IFFViewer for IFF images"
                )
                
                FeatureView(
                    title: "Disk Analysis",
                    description: "You can now compare two images by sectors. This is useful for checking for data corruption or comparing two versions of an image."
                )
            }
            
            Spacer()

            HStack {
                Toggle("Don't show this message again", isOn: $dontShowWhatsNew)
                Spacer()
                Button("Dismiss") {
                    showWhatsNew = false
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(30)
        .frame(width: 450, height: 300)
    }
}

// Helper view for displaying a feature.
struct FeatureView: View {
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .font(.title)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(description)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    WhatsNewView(showWhatsNew: .constant(true))
}
