//
//  AboutView.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import SwiftUI

struct AboutView: View {
    // This property will hold the correct close action,
    // provided by whichever view presents this one.
    var closeAction: () -> Void

    // These will get the values from your app's Info.plist
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
            if let nsImage = NSApp.applicationIconImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.accentColor)
            }

            Text(appName)
                .font(.title2.weight(.semibold))

            Text("Version \(appVersion) (Build \(buildNumber))")
                .font(.callout)
                .foregroundColor(.secondary)

            Text("A modern player for classic Amiga audio formats. Created by Mario Esposito.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)


            Divider()

            Text("CONTRIBUTIONS & DEV TIPS")
                .font(.caption.weight(.semibold))
            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    Link("🔌 Powered by libopenmpt", destination: URL(string: "https://lib.openmpt.org/libopenmpt/")!)
                    Link("🎨 Some icons by thiings.co", destination: URL(string: "https://www.thiings.co/things")!)
                    Link("🐛 Report bugs or suggest features", destination: URL(string: "https://github.com/GINNOV/littlethings/issues")!)
                    Text("❣️ Lots of love from the community.")
                }
            }
            .font(.caption)
            .padding(.bottom)

            // The button now calls the provided closeAction.
            Button("Close") {
                closeAction()
            }
            .keyboardShortcut(.cancelAction)
        }
        .padding(30)
        .frame(minWidth: 400, idealWidth: 450)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        // Update the preview to provide a dummy action.
        AboutView(closeAction: {})
    }
}
