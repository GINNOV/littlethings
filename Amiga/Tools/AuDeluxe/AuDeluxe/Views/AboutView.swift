//
//  AboutView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }
    var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
    }
    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "AuDeluxe"
    }

    var body: some View {
        VStack(spacing: 15) {
            if let nsImage = NSImage(named: NSImage.applicationIconName) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
            }

            Text(appName)
                .font(.largeTitle.weight(.thin))

            Text("Version \(appVersion) (Build \(buildNumber))")
                .font(.callout)
                .foregroundColor(.secondary)

            Text("A modern player for classic Amiga audio formats.\nCreated by Mario Esposito.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom)

            Divider()
            
            VStack {
                Text("Powered by libopenmpt").fontWeight(.bold)
                Text("Some icons by SF Symbols")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            Spacer()

            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
        }
        .padding(30)
        .frame(minWidth: 400, idealWidth: 400, minHeight: 400)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
