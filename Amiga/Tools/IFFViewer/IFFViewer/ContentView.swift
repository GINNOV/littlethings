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
    @State private var showingAbout = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main content
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
                }

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .textBackgroundColor))
                    
                    if text.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("This application installs a Quick Look plugin for viewing IFF/ILBM image files, a format popular on the Amiga computer.")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                
                                Text("How to use:")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                
                                Text("1. Keep this app in your Applications folder.")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                
                                Text("2. Run the app once to register the plugin with macOS.")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                
                                Text("3. Quit this app (you don't need to keep it running).")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                
                                Text("4. Select any .iff or .lbm file in Finder and press the Spacebar to see a preview!")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text("TIP: Lots of IFF files available")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.secondary)
                                    
                                    Link("HERE",
                                         destination: URL(string: "https://aminet.net/search?f=2&path=pix/clip")!)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.blue)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                    } else {
                        TextEditor(text: $text)
                            .padding(EdgeInsets(top: 6, leading: 4, bottom: 8, trailing: 4))
                            .font(.system(.body, design: .monospaced))
                            .scrollContentBackground(.hidden) // Makes the TextEditor background transparent.
                    }
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
            
            // Info button overlay
            Button(action: {
                showingAbout.toggle()
            }) {
                Image(systemName: "info.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .background(Color.clear)
            }
            .buttonStyle(.plain)
            .padding(.top, 20)
            .padding(.trailing, 20)
            .help("About") // Adds a tooltip on hover
            
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
