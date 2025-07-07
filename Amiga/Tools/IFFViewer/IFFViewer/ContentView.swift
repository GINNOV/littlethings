//
//  ContentView.swift
//  IFFViewer
//
//  Created by Mario Esposito on 7/7/25.
//

import SwiftUI

struct ContentView: View {
    private let placeholderText = """
    This application installs a Quick Look plugin for viewing IFF/ILBM image files, a format popular on the Amiga computer.

    How to use:
    1. Keep this app in your Applications folder.
    2. Run the app once to register the plugin with macOS.
    3. Quit this app (you don't need to keep it running).
    4. Select any .iff or .lbm file in Finder and press the Spacebar to see a preview!
    
    TIP: Lots of IFF files available here: https://aminet.net/search?f=2&path=pix/clip
    """
    @State private var text: String = ""

    // Helper computed properties to get version and build number from the bundle.
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }

    var body: some View {
        VStack(spacing: 25) {
            Image("amiga-dev-hub")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 280)
                .clipShape(Circle())
                .shadow(color: .gray.opacity(0.6), radius: 10, x: 0, y: 5)
                .padding(.top)

            VStack {
                Text("IFF Quick Look Plugin")
                    .font(.system(size: 32, weight: .thin, design: .default))
                Text("from Back To Amiga Dev Hub")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .textBackgroundColor))
                
                if text.isEmpty {
                    Text(placeholderText)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding()
                        .allowsHitTesting(false) // Lets clicks pass through to the TextEditor below.
                }
                
                TextEditor(text: $text)
                    .padding(EdgeInsets(top: 6, leading: 4, bottom: 8, trailing: 4))
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden) // Makes the TextEditor background transparent.
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
            .frame(height: 250)

            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Quit")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .shadow(radius: 5)
        }
        .padding(40)
        .frame(width: 550, height: 675)
        
        Text("Version \(appVersion) (Build \(appBuild))")
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
