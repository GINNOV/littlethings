import SwiftUI
import WebKit

struct WebEmulatorView: NSViewRepresentable {
    @Binding var adfTrigger: Int
    let adfPath: String
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebEmulatorView
        
        init(_ parent: WebEmulatorView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Inject ADF if loading occurred after compilation
            if parent.adfTrigger > 0 {
                // Delay slightly to let the WASM interface initialize fully
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.injectADF(into: webView)
                }
            }
        }
        
        func injectADF(into webView: WKWebView) {
            let fileURL = URL(fileURLWithPath: parent.adfPath)
            guard FileManager.default.fileExists(atPath: parent.adfPath) else {
                print("ADF file does not exist at path: \(parent.adfPath)")
                return
            }
            
            guard let buffer = try? Data(contentsOf: fileURL) else {
                print("Failed to read ADF file data from: \(parent.adfPath)")
                return
            }
            
            let base64 = buffer.base64EncodedString()
            let fileName = fileURL.lastPathComponent
            
            let jsScript = """
            (async function() {
                try {
                    const res = await fetch("data:application/octet-stream;base64,\(base64)");
                    const blob = await res.blob();
                    const file = new File([blob], "\(fileName)", { type: "application/octet-stream" });
                    
                    const canvas = document.querySelector("#canvas") || document.body;
                    const dataTransfer = new DataTransfer();
                    dataTransfer.items.add(file);
                    
                    const dragOverEvent = new DragEvent("dragover", {
                        bubbles: true,
                        cancelable: true,
                        dataTransfer: dataTransfer
                    });
                    const dropEvent = new DragEvent("drop", {
                        bubbles: true,
                        cancelable: true,
                        dataTransfer: dataTransfer
                    });
                    
                    canvas.dispatchEvent(dragOverEvent);
                    canvas.dispatchEvent(dropEvent);
                    console.log("ADF \(fileName) injected successfully via WebKit drag-and-drop.");
                } catch(err) {
                    console.error("Failed to inject ADF: " + err.message);
                }
            })();
            """
            
            webView.evaluateJavaScript(jsScript) { result, error in
                if let error = error {
                    print("JS evaluation failed: \(error.localizedDescription)")
                } else {
                    print("Simulated drop script executed in WKWebView.")
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        // Allow scripts and developer inspector if desired
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        if let url = URL(string: "https://vamigaweb.github.io/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // If trigger changes (meaning new compile was run), inject the ADF
        if adfTrigger > 0 {
            context.coordinator.injectADF(into: nsView)
        }
    }
}
