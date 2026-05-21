import SwiftUI
import Combine
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var llm = OllamaService.shared

    // Editor State
    @State private var codeText: String = """
; ==========================================================
;   Amiga 68000 Copper List Example
;   Generates a classic vertical raster rainbow bar
;   (System-friendly graphics.library takeover)
; ==========================================================

            SECTION    Code,CODE,CHIP       ; Must be in CHIP RAM!

            XDEF       _StartCopper
_StartCopper:
            movem.l    d2-d7/a2-a6,-(sp)    ; Save registers

            ; 1. Open Graphics Library
            move.l     $4.w,a6              ; ExecBase
            lea        gfxName(pc),a1
            moveq      #0,d0
            jsr        -408(a6)             ; OpenLibrary
            move.l     d0,GfxBase
            beq.s      .exit

            ; 2. Shut down OS View/Display (System-friendly loadview)
            move.l     GfxBase(pc),a6
            move.l     34(a6),oldView       ; Save GfxBase->ActiView (offset 34)

            sub.l      a1,a1                ; Load NULL view (turns off OS screen)
            jsr        -222(a6)             ; LoadView(NULL)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; Double WaitTOF for interlaced setup

            ; 3. Setup Custom Copper List
            lea        $dff000,a5
            lea        CopperList(pc),a0
            move.l     a0,$80(a5)           ; Write COP1LC ($DFF080)
            move.w     #$0000,$88(a5)       ; Strobe COPJMP1 ($DFF088) to activate

            ; Enable copper DMA
            move.w     #$8280,$96(a5)       ; DMACON: set COPEN and DMAEN

.waitButton:
            ; Wait for left mouse button (Port $bfe001, bit 6)
            btst       #6,$bfe001
            bne.s      .waitButton

            ; 4. Restore OS View and Copper
            move.l     GfxBase(pc),a6
            move.l     oldView(pc),a1       ; Load old view pointer
            jsr        -222(a6)             ; LoadView(oldView)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; WaitTOF()

            ; Close Graphics Library
            move.l     $4.w,a6
            move.l     GfxBase(pc),a1
            jsr        -414(a6)             ; CloseLibrary

.exit:
            movem.l    (sp)+,d2-d7/a2-a6    ; Restore registers
            moveq      #0,d0                ; Return 0
            rts

gfxName:    dc.b       "graphics.library",0
            EVEN
GfxBase:    dc.l       0
oldView:    dc.l       0

            ALIGN      4
CopperList:
            ; Custom screen copper instructions
            dc.w       $0100,$0200          ; BPLCON0: disable all bitplanes (black screen)

            ; Vertical color raster splits
            dc.w       $5007,$fffe          ; Wait for line 80
            dc.w       $0180,$0f00          ; Color 0 = Red
            dc.w       $5807,$fffe          ; Wait for line 88
            dc.w       $0180,$0f70          ; Color 0 = Orange
            dc.w       $6007,$fffe          ; Wait for line 96
            dc.w       $0180,$0ff0          ; Color 0 = Yellow
            dc.w       $6807,$fffe          ; Wait for line 104
            dc.w       $0180,$00f0          ; Color 0 = Green
            dc.w       $7007,$fffe          ; Wait for line 112
            dc.w       $0180,$00ff          ; Color 0 = Cyan
            dc.w       $7807,$fffe          ; Wait for line 120
            dc.w       $0180,$000f          ; Color 0 = Blue
            dc.w       $8007,$fffe          ; Wait for line 128
            dc.w       $0180,$0f0f          ; Color 0 = Purple
            dc.w       $8807,$fffe          ; Wait for line 136
            dc.w       $0180,$0000          ; Color 0 = Black

            dc.w       $ffff,$fffe          ; End of copper list
"""


    // Persisted Amiga Hardware Settings
    @AppStorage("emulatorModel") private var emulatorModel: String = "A500"
    @AppStorage("emulatorCpu") private var emulatorCpu: String = "68000"
    @AppStorage("emulatorChipRam") private var emulatorChipRam: String = "512 KB"
    @AppStorage("emulatorFastRam") private var emulatorFastRam: String = "0 MB"
    @AppStorage("emulatorJit") private var emulatorJit: Bool = false
    @AppStorage("selectedRomFilename") private var selectedRomFilename: String = ""
    @AppStorage("emulatorCustomArgs") private var emulatorCustomArgs: String = ""
    @AppStorage("emulatorBackend") private var emulatorBackend: String = EmulatorBackend.fsUAE.rawValue
    @AppStorage("vAmigaExecutablePath") private var vAmigaExecutablePath: String = "/Applications/vAmiga.app/Contents/MacOS/vAmiga"
    @AppStorage("vAmigaCustomArgs") private var vAmigaCustomArgs: String = ""
    @AppStorage("autoRunEmulator") private var autoRunEmulator: Bool = false

    // Compilation & Output State
    @State private var outputConsole: String = "VASM Compiler Idle.\nPress 'Assemble [F5]' to build the program."
    @State private var isCompiling: Bool = false
    @State private var isExportingADF: Bool = false
    @State private var compileSuccess: Bool = true
    @State private var isShowingSettings: Bool = false
    @State private var adfTrigger: Int = 0
    @State private var isShowingWebEmulator: Bool = false

    private var selectedBackend: EmulatorBackend {
        EmulatorBackend(rawValue: emulatorBackend) ?? .fsUAE
    }

    private var selectedBackendName: String {
        selectedBackend.displayName
    }

    // Chat Panel State
    @State private var chatHistory: [OllamaService.ChatMessage] = []
    @State private var currentMessage: String = ""
    @State private var isGenerating: Bool = false
    @State private var currentGeneration: String = ""

    // Examples Database
    static let examples: [String: String] = [
        "Copper Rainbow": """
; ==========================================================
;   Amiga 68000 Copper List Example
;   Generates a classic vertical raster rainbow bar
;   (System-friendly graphics.library takeover)
; ==========================================================
            SECTION    Code,CODE,CHIP       ; Must be in CHIP RAM!
            XDEF       _Start
_Start:
            movem.l    d2-d7/a2-a6,-(sp)    ; Save registers

            ; 1. Open Graphics Library
            move.l     $4.w,a6              ; ExecBase
            lea        gfxName(pc),a1
            moveq      #0,d0
            jsr        -408(a6)             ; OpenLibrary
            move.l     d0,GfxBase
            beq.s      .exit

            ; 2. Shut down OS View/Display (System-friendly loadview)
            move.l     GfxBase(pc),a6
            move.l     34(a6),oldView       ; Save GfxBase->ActiView

            sub.l      a1,a1                ; Load NULL view (turns off OS screen)
            jsr        -222(a6)             ; LoadView(NULL)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; Double WaitTOF

            ; 3. Setup Custom Copper List
            lea        $dff000,a5
            lea        CopperList(pc),a0
            move.l     a0,$80(a5)           ; Write COP1LC ($DFF080)
            move.w     #$0000,$88(a5)       ; Strobe COPJMP1 ($DFF088) to activate

            ; Enable copper DMA
            move.w     #$8280,$96(a5)       ; DMACON: set COPEN and DMAEN

.waitButton:
            ; Wait for left mouse button (Port $bfe001, bit 6)
            btst       #6,$bfe001
            bne.s      .waitButton

            ; 4. Restore OS View and Copper
            move.l     GfxBase(pc),a6
            move.l     oldView(pc),a1       ; Load old view pointer
            jsr        -222(a6)             ; LoadView(oldView)
            jsr        -270(a6)             ; WaitTOF()
            jsr        -270(a6)             ; WaitTOF()

            ; Close Graphics Library
            move.l     $4.w,a6
            move.l     GfxBase(pc),a1
            jsr        -414(a6)             ; CloseLibrary

.exit:
            movem.l    (sp)+,d2-d7/a2-a6    ; Restore registers
            moveq      #0,d0                ; Return 0
            rts

gfxName:    dc.b       "graphics.library",0
            EVEN
GfxBase:    dc.l       0
oldView:    dc.l       0

            ALIGN      4
CopperList:
            dc.w       $0100,$0200          ; No planes
            dc.w       $5007,$fffe          ; Wait for line 80
            dc.w       $0180,$0f00          ; Red
            dc.w       $5807,$fffe          ; Wait for line 88
            dc.w       $0180,$0f70          ; Orange
            dc.w       $6007,$fffe          ; Wait for line 96
            dc.w       $0180,$0ff0          ; Yellow
            dc.w       $6807,$fffe          ; Wait for line 104
            dc.w       $0180,$00f0          ; Green
            dc.w       $7007,$fffe          ; Wait for line 112
            dc.w       $0180,$00ff          ; Cyan
            dc.w       $7807,$fffe          ; Wait for line 120
            dc.w       $0180,$000f          ; Blue
            dc.w       $8007,$fffe          ; Wait for line 128
            dc.w       $0180,$0f0f          ; Purple
            dc.w       $8807,$fffe          ; Wait for line 136
            dc.w       $0180,$0000          ; Black
            dc.w       $ffff,$fffe          ; End of copper list
""",
        "Joystick Reader": """
; ==========================================================
;   Amiga 68000 Joystick Detection Example
; ==========================================================
            SECTION    Code,CODE
            XDEF       _ReadJoy
_ReadJoy:
            move.w     $dff00c,d0           ; Read JOY1DAT (Joystick 1 Port)

            ; Decode directions
            move.w     d0,d1
            and.w      #$0001,d1            ; Bit 0: Y-axis XOR (Forward)

            move.w     d0,d2
            and.w      #$0002,d2            ; Bit 1: X-axis XOR (Right)

            ; Test for Fire button (Port $bfe001 bit 7 for Joy 0 / CIA bit for Joy 1)
            ; Typically check Game Port 1 custom pin registers
            moveq      #0,d0
            rts
""",
        "Audio Sine Player": """
; ==========================================================
;   Amiga 68000 Audio Sine Channel 0 Example
; ==========================================================
            SECTION    Code,CODE
            XDEF       _PlayAudio
_PlayAudio:
            lea        $dff000,a6

            ; 1. Set channel 0 pointer to sample data
            lea        SineWave(pc),a0
            move.l     a0,$a0(a6)           ; AUD0LCH/AUD0LCL

            ; 2. Set sample length (in words)
            move.w     #4,$a4(a6)           ; AUD0LEN (8 bytes = 4 words)

            ; 3. Set volume (0 to 64)
            move.w     #64,$a8(a6)          ; AUD0VOL (Max)

            ; 4. Set period (lower = higher pitch)
            move.w     #428,$a6(a6)         ; AUD0PER (~440Hz Sine)

            ; 5. Enable audio DMA channel 0
            move.w     #$8201,$96(a6)       ; DMACON: AUD0EN and DMAEN
            rts

            ALIGN      4
SineWave:
            ; 8-bit signed audio sample wave data (8 bytes)
            dc.b       0, 90, 127, 90, 0, -90, -127, -90
"""
    ]

    var examples: [String: String] {
        ContentView.examples
    }

    var body: some View {
        VStack(spacing: 0) {
            // Amiga Classic Top Workbench Window Title Bar
            HStack {
                Text("Amiga Workbench v3.9")
                    .fontWeight(.bold)
                Spacer()
                Text("Chip Mem: 2,048,000  |  Fast Mem: 16,777,216  |  68020 Active  |  Ollama Connected")
                    .font(.system(.caption, design: .monospaced))
                Spacer()
                HStack(spacing: 4) {
                    Circle().fill(Color.orange).frame(width: 8, height: 8)
                    Circle().fill(Color.gray).frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(red: 0.8, green: 0.8, blue: 0.8))
            .foregroundColor(.black)
            .shadow(color: .black.opacity(0.3), radius: 1, y: 1)

            // Top Editor Custom Action Toolbar
            HStack(spacing: 12) {
                Button(action: runCompilation) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Assemble [F5]")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isCompiling ? Color.gray : Color(red: 0.0, green: 0.6, blue: 0.2))
                    .cornerRadius(4)
                    .foregroundColor(.white)
                }
                .disabled(isCompiling || isExportingADF)

                Button(action: runInEmulator) {
                    HStack {
                        Image(systemName: "play.tv")
                        Text("Run in \(selectedBackendName) [F6]")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isCompiling ? Color.gray : Color(red: 0.0, green: 0.47, blue: 0.8))
                    .cornerRadius(4)
                    .foregroundColor(.white)
                }
                .disabled(isCompiling || isExportingADF)

                Button(action: validateInVAmiga) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Validate vAmiga [F8]")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isCompiling ? Color.gray : Color(red: 0.8, green: 0.45, blue: 0.0))
                    .cornerRadius(4)
                    .foregroundColor(.white)
                }
                .disabled(isCompiling || isExportingADF)

                Button(action: runInWebEmulator) {
                    HStack {
                        Image(systemName: "safari")
                        Text("Web Emulator [F7]")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isCompiling ? Color.gray : Color(red: 0.5, green: 0.0, blue: 0.8))
                    .cornerRadius(4)
                    .foregroundColor(.white)
                }
                .disabled(isCompiling || isExportingADF)

                Button(action: { isShowingSettings = true }) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.25, green: 0.25, blue: 0.3))
                    .cornerRadius(4)
                    .foregroundColor(.white)
                }

                Button(action: exportToADF) {
                    HStack {
                        Image(systemName: "opticaldisc")
                        Text("Export Bootable ADF")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background((isCompiling || isExportingADF) ? Color.gray : Color(red: 0.85, green: 0.45, blue: 0.0))
                    .cornerRadius(4)
                    .foregroundColor(.white)
                }
                .disabled(isCompiling || isExportingADF)

                Menu("Load Gold Examples") {
                    ForEach(Array(examples.keys), id: \.self) { key in
                        Button(key) {
                            codeText = examples[key] ?? ""
                            outputConsole = "Loaded '\(key)' example assembly source code."
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                .cornerRadius(4)
                .foregroundColor(.white)

                Button("Clear Editor") {
                    codeText = ""
                    outputConsole = "Editor Cleared."
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 0.7, green: 0.2, blue: 0.2))
                .cornerRadius(4)
                .foregroundColor(.white)

                Spacer()

                // Active status indicators
                HStack(spacing: 6) {
                    Text(compileSuccess ? "VALID" : "COMPILER ERROR")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(compileSuccess ? .green : .red)
                    Circle()
                        .fill(compileSuccess ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                }
            }
            .padding(10)
            .background(Color(red: 0.15, green: 0.15, blue: 0.18))

            HSplitView {
                // LEFT: Retro Sidebar Chat
                VStack(spacing: 0) {
                    // Settings Panel Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ASSISTANT SETTINGS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)

                        HStack(spacing: 0) {
                            ForEach(OllamaService.Provider.allCases, id: \.self) { prov in
                                Button(action: {
                                    llm.provider = prov
                                }) {
                                    Text(prov.rawValue)
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .padding(.vertical, 6)
                                        .frame(maxWidth: .infinity)
                                        .background(llm.provider == prov ? Color.orange : Color(red: 0.18, green: 0.18, blue: 0.22))
                                        .foregroundColor(llm.provider == prov ? Color.black : Color.white)
                                }
                                .buttonStyle(PlainButtonStyle())
                                if prov != OllamaService.Provider.allCases.last {
                                    Spacer().frame(width: 1)
                                }
                            }
                        }
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange, lineWidth: 1))

                        HStack {
                            Text("Model:")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.white)
                            TextField("", text: $llm.modelName)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color(red: 0.18, green: 0.18, blue: 0.22))
                                .cornerRadius(4)
                                .foregroundColor(.white)
                                .font(.system(.body, design: .monospaced))
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange.opacity(0.5), lineWidth: 1))
                        }
                    }
                    .padding(10)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.12))

                    Divider().background(Color.orange)

                    // Chat messages window
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                if chatHistory.isEmpty {
                                    VStack(alignment: .center, spacing: 8) {
                                        Text("👾 Antigravity 68k Amiga AI 👾")
                                            .font(.headline)
                                            .foregroundColor(.orange)
                                        Text("Ask me to write custom copper lists, blitter copies, joystick reading code, or audio players. The generated code is optimized and validated for vasm.")
                                            .font(.caption)
                                            .foregroundColor(.white) // Crisp white text
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal)
                                    }
                                    .padding(.top, 40)
                                } else {
                                    ForEach(chatHistory) { msg in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(msg.role == "user" ? "👤 USER:" : "💾 AMIGA ASSISTANT:")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(msg.role == "user" ? .cyan : .orange)

                                            Text(msg.content)
                                                .font(.system(.body, design: .monospaced))
                                                .foregroundColor(.white) // Crisp white text
                                                .padding(8)
                                                .background(msg.role == "user" ? Color.blue.opacity(0.2) : Color.orange.opacity(0.12))
                                                .cornerRadius(6)
                                                .textSelection(.enabled)

                                            // Quick Code Inject Button
                                            if msg.role == "assistant" && msg.content.contains("SECTION") {
                                                Button(action: {
                                                    injectCodeBlock(from: msg.content)
                                                }) {
                                                    HStack {
                                                        Image(systemName: "arrow.right.doc.on.clipboard")
                                                        Text("Inject Code into Editor")
                                                    }
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.orange)
                                                    .cornerRadius(4)
                                                    .foregroundColor(.black)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .id(msg.id)
                                    }
                                }

                                if isGenerating {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("💾 AMIGA ASSISTANT:")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.orange)
                                        Text(currentGeneration)
                                            .font(.system(.body, design: .monospaced))
                                            .foregroundColor(.white) // Crisp white text
                                            .padding(8)
                                            .background(Color.orange.opacity(0.12))
                                            .cornerRadius(6)
                                    }
                                    .padding(.horizontal, 10)
                                    .id("generation")
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .onChange(of: chatHistory.count) {
                            if let last = chatHistory.last {
                                withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                            }
                        }
                        .onChange(of: currentGeneration) {
                            proxy.scrollTo("generation", anchor: .bottom)
                        }
                    }

                    Spacer()

                    // Rotating Boing Ball integrated inside lower chat layout!
                    BoingBallView()
                        .padding(.vertical, 8)

                    Divider().background(Color.orange)

                    // Input Bar
                    HStack(spacing: 8) {
                        TextField("Ask Amiga Assistant...", text: $currentMessage, onCommit: sendMessage)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.18, green: 0.18, blue: 0.22))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange.opacity(0.5), lineWidth: 1))
                            .disabled(isGenerating)

                        Button(action: sendMessage) {
                            Text("Send")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(isGenerating ? Color.gray : Color.orange)
                                .cornerRadius(4)
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                        }
                        .disabled(isGenerating)
                    }
                    .padding(10)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.12))
                }
                .frame(minWidth: 320, maxWidth: 450)
                .background(Color(red: 0.08, green: 0.08, blue: 0.1))

                // RIGHT: Split Code Editor + VASM Console output
                VSplitView {
                    // UPPER: Retro Custom Assembly Code Editor
                    HStack(spacing: 0) {
                        // Custom Synchronized Line Numbers column
                        VStack(alignment: .trailing, spacing: 4) {
                            ForEach(1...max(codeText.components(separatedBy: "\n").count, 1), id: \.self) { line in
                                Text("\(line)")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.gray)
                                    .frame(height: 18)
                            }
                        }
                        .padding(.leading, 6)
                        .padding(.trailing, 10)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.05, green: 0.12, blue: 0.25))

                        // Text Editor with Deep Amiga Blue theme
                        TextEditor(text: $codeText)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .scrollContentBackground(.hidden)
                            .background(Color(red: 0.0, green: 0.18, blue: 0.35)) // Deep Classic Blue
                            .cornerRadius(4)
                    }
                    .frame(minHeight: 250)

                    // LOWER: Dual-mode VASM Console or WebEmulatorView
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            Button(action: { isShowingWebEmulator = false }) {
                                HStack {
                                    Image(systemName: "terminal.fill")
                                    Text("📟 VASM CONSOLE")
                                }
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(!isShowingWebEmulator ? Color(red: 0.15, green: 0.15, blue: 0.18) : Color.black)
                                .foregroundColor(!isShowingWebEmulator ? .orange : .gray)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Button(action: { isShowingWebEmulator = true }) {
                                HStack {
                                    Image(systemName: "safari.fill")
                                    Text("🕹️ WEB EMULATOR")
                                }
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isShowingWebEmulator ? Color(red: 0.15, green: 0.15, blue: 0.18) : Color.black)
                                .foregroundColor(isShowingWebEmulator ? .orange : .gray)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Spacer()

                            HStack(spacing: 6) {
                                Text(compileSuccess ? "VALID" : "ERROR")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(compileSuccess ? .green : .red)
                                Circle()
                                    .fill(compileSuccess ? Color.green : Color.red)
                                    .frame(width: 8, height: 8)
                            }
                            .padding(.trailing, 10)
                        }
                        .background(Color.black)

                        if !isShowingWebEmulator {
                            ScrollView {
                                Text(outputConsole)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(Color.black)
                        } else {
                            WebEmulatorView(adfTrigger: $adfTrigger, adfPath: "/tmp/amiga_playground_temp.adf")
                                .background(Color.black)
                        }
                    }
                    .frame(minHeight: 180, maxHeight: 400)
                }
            }
        }
        .frame(minWidth: 900, minHeight: 650)
        .background(Color.black)
        .sheet(isPresented: $isShowingSettings) {
            SettingsView(isPresented: $isShowingSettings)
        }
    }

    // Assemble the code using VASM Process helper
    private func runCompilation() {
        if autoRunEmulator {
            runInEmulator()
            return
        }

        isCompiling = true
        outputConsole = "Assembling code using vasmm68k_mot...\n"

        CompilerService.shared.compile(assemblyCode: codeText) { success, output in
            self.isCompiling = false
            self.compileSuccess = success
            self.outputConsole = output
        }
    }

    private func runInEmulator() {
        runNativeEmulator(
            backend: selectedBackend,
            label: selectedBackendName,
            openingMessage: "Assembling code and packaging bootable ADF for \(selectedBackendName)...\n"
        )
    }

    // Validate compiled code by forcing the native vAmiga RetroShell trace backend.
    private func validateInVAmiga() {
        runNativeEmulator(
            backend: .vAmiga,
            label: EmulatorBackend.vAmiga.displayName,
            openingMessage: "Validating code by building a bootable ADF and launching it in vAmiga RetroShell...\n"
        )
    }

    // Build a bootable ADF and run it in a native emulator backend.
    private func runNativeEmulator(backend: EmulatorBackend, label: String, openingMessage: String) {
        isCompiling = true
        isShowingWebEmulator = false
        outputConsole = openingMessage

        let tempADFPath = "/tmp/amiga_playground_temp.adf"

        CompilerService.shared.generateBootableADF(assemblyCode: codeText, targetADFPath: tempADFPath) { success, resultMessage in
            if !success {
                self.isCompiling = false
                self.compileSuccess = false
                self.outputConsole = resultMessage
                return
            }

            self.outputConsole = resultMessage + "\n\nLaunching \(label) with selected ROM and configuration..."

            let launchConfig = EmulatorLaunchConfig(
                backend: backend,
                adfPath: tempADFPath,
                romRelativePath: self.selectedRomFilename,
                model: self.emulatorModel,
                chipRamMb: self.emulatorChipRam,
                fastRamMb: self.emulatorFastRam,
                cpu: self.emulatorCpu,
                jit: self.emulatorJit,
                customArgs: self.emulatorCustomArgs,
                vAmigaExecutablePath: self.vAmigaExecutablePath,
                vAmigaCustomArgs: self.vAmigaCustomArgs
            )

            EmulatorService.shared.launchEmulator(config: launchConfig) { result in
                self.isCompiling = false
                self.compileSuccess = result.success
                self.outputConsole = self.outputConsole + "\n\n" + result.message
                if let tracePath = result.tracePath {
                    self.outputConsole += "\n\nValidation Trace Output:\n\(tracePath)"
                }
            }
        }
    }

    // Run compiled code in Embedded Web Emulator (vAmigaWeb Option B)
    private func runInWebEmulator() {
        isCompiling = true
        isShowingWebEmulator = true
        outputConsole = "Assembling code and packaging bootable ADF for Web Emulator...\n"

        let tempADFPath = "/tmp/amiga_playground_temp.adf"

        CompilerService.shared.generateBootableADF(assemblyCode: codeText, targetADFPath: tempADFPath) { success, resultMessage in
            self.isCompiling = false
            self.compileSuccess = success
            self.outputConsole = resultMessage

            if success {
                // Increment trigger to notify WKWebView updateNSView to inject ADF file
                self.adfTrigger += 1
            }
        }
    }

    // Interfacing with local LLM APIs
    private func sendMessage() {
        guard !currentMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let userMsg = OllamaService.ChatMessage(role: "user", content: currentMessage)
        chatHistory.append(userMsg)

        currentMessage = ""
        isGenerating = true
        currentGeneration = ""

        // Assemble conversation history for prompt
        let history = chatHistory

        OllamaService.shared.streamChat(
            messages: history,
            onChunk: { chunk in
                currentGeneration += chunk
            },
            onCompletion: { fullResponse in
                isGenerating = false
                let assistantMsg = OllamaService.ChatMessage(role: "assistant", content: fullResponse)
                chatHistory.append(assistantMsg)
            },
            onError: { error in
                isGenerating = false
                let errorMsg = OllamaService.ChatMessage(role: "assistant", content: "Connection Error: \(error.localizedDescription)\nEnsure your LLM server (Ollama/LM Studio) is running on the specified port.")
                chatHistory.append(errorMsg)
            }
        )
    }

    // Simple helper to isolate block between markdown fences and overwrite the editor
    private func injectCodeBlock(from responseText: String) {
        if let range = responseText.range(of: "```[a-zA-Z0-9]*\n", options: .regularExpression) {
            let codeStart = responseText.index(range.upperBound, offsetBy: 0)
            if let endRange = responseText[codeStart...].range(of: "```") {
                let codeContent = responseText[codeStart..<endRange.lowerBound]
                self.codeText = String(codeContent).trimmingCharacters(in: .whitespacesAndNewlines)
                self.outputConsole = "Injected code block from Amiga Assistant."
                return
            }
        }

        // Fallback if no code fences are found
        self.codeText = responseText
        self.outputConsole = "Injected full assistant text block."
    }

    // ADF Generation Helpers
    private func exportToADF() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType(filenameExtension: "adf")].compactMap { $0 }
        savePanel.nameFieldStringValue = "amiga_playground.adf"
        savePanel.title = "Export Bootable ADF"
        savePanel.message = "Choose where to save your bootable Amiga Disk File (ADF)."

        savePanel.begin { response in
            if response == .OK, let targetURL = savePanel.url {
                self.generateADF(at: targetURL)
            }
        }
    }

    private func generateADF(at url: URL) {
        self.isExportingADF = true
        self.outputConsole = "Generating bootable ADF disk image at:\n\(url.path)...\n"

        CompilerService.shared.generateBootableADF(assemblyCode: codeText, targetADFPath: url.path) { success, resultMessage in
            self.isExportingADF = false
            self.compileSuccess = success
            self.outputConsole = resultMessage
        }
    }
}

struct SettingsView: View {
    @Binding var isPresented: Bool

    @AppStorage("emulatorModel") private var emulatorModel: String = "A500"
    @AppStorage("emulatorCpu") private var emulatorCpu: String = "68000"
    @AppStorage("emulatorChipRam") private var emulatorChipRam: String = "512 KB"
    @AppStorage("emulatorFastRam") private var emulatorFastRam: String = "0 MB"
    @AppStorage("emulatorJit") private var emulatorJit: Bool = false
    @AppStorage("selectedRomFilename") private var selectedRomFilename: String = ""
    @AppStorage("emulatorCustomArgs") private var emulatorCustomArgs: String = ""
    @AppStorage("emulatorBackend") private var emulatorBackend: String = EmulatorBackend.fsUAE.rawValue
    @AppStorage("vAmigaExecutablePath") private var vAmigaExecutablePath: String = "/Applications/vAmiga.app/Contents/MacOS/vAmiga"
    @AppStorage("vAmigaCustomArgs") private var vAmigaCustomArgs: String = ""
    @AppStorage("autoRunEmulator") private var autoRunEmulator: Bool = false
    @AppStorage("romsDirectoryPath") private var romsDirectoryPath: String = "/Users/megov/code/GitHub/littlethings/Amiga/commodore-amiga-firmware"

    @State private var availableRoms: [RomEntry] = []

    let models = ["A500", "A500+", "A600", "A1000", "A1200", "A2000", "A3000", "A4000"]
    let cpus = ["68000", "68010", "68020", "68030", "68040", "68060"]
    let chipRams = ["512 KB", "1 MB", "2 MB", "4 MB", "8 MB"]
    let fastRams = ["0 MB", "1 MB", "2 MB", "4 MB", "8 MB", "16 MB", "32 MB", "64 MB"]

    private var selectedRomDisplayName: String {
        if selectedRomFilename.isEmpty {
            return "Default / vAmiga configured ROM"
        }

        return availableRoms.first(where: { $0.relativePath == selectedRomFilename })?.displayName ?? selectedRomFilename
    }

    private func chooseRomsDirectory() {
        let panel = NSOpenPanel()
        panel.title = "Select Kickstart ROM Directory"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        if !romsDirectoryPath.isEmpty && FileManager.default.fileExists(atPath: romsDirectoryPath) {
            panel.directoryURL = URL(fileURLWithPath: romsDirectoryPath)
        }

        if panel.runModal() == .OK {
            if let path = panel.url?.path {
                self.romsDirectoryPath = path
                self.availableRoms = EmulatorService.shared.getAvailableRoms()
                if !selectedRomFilename.isEmpty && !availableRoms.contains(where: { $0.relativePath == selectedRomFilename }) {
                    selectedRomFilename = ""
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header bar in Workbench look
            HStack {
                Text("Amiga Hardware Preferences")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.black)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(red: 0.8, green: 0.8, blue: 0.8))
            .foregroundColor(.black)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NATIVE EMULATOR BACKEND")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)

                        Picker("Backend:", selection: $emulatorBackend) {
                            ForEach(EmulatorBackend.allCases) { backend in
                                Text(backend.displayName).tag(backend.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        Text("vAmiga CPU Trace uses vAmiga Desktop RetroShell scripts and captures trace output for LLM review.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(12)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.12))
                    .cornerRadius(6)

                    // Kickstart Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("KICKSTART ROM SELECTION")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)

                        Text("Active ROM directory: \(romsDirectoryPath)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)

                        HStack(spacing: 12) {
                            Button(action: {
                                chooseRomsDirectory()
                            }) {
                                Text("Choose Folder...")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange)
                                    .foregroundColor(.black)
                                    .cornerRadius(4)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Button(action: {
                                romsDirectoryPath = "/Users/megov/code/GitHub/littlethings/Amiga/commodore-amiga-firmware"
                                availableRoms = EmulatorService.shared.getAvailableRoms()
                                if !selectedRomFilename.isEmpty && !availableRoms.contains(where: { $0.relativePath == selectedRomFilename }) {
                                    selectedRomFilename = ""
                                }
                            }) {
                                Text("Reset to Default")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(red: 0.25, green: 0.25, blue: 0.28))
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 4)

                        if availableRoms.isEmpty {
                            Text("No ROM files found in '\(romsDirectoryPath)'. Add legal ROM files or choose a different directory.")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(4)
                        } else {
                            SettingsPickerField(
                                title: "Select Kickstart ROM",
                                displayValue: selectedRomDisplayName,
                                selection: $selectedRomFilename
                            ) {
                                Text("Default / vAmiga configured ROM").tag("")
                                ForEach(availableRoms) { rom in
                                    Text(rom.displayName).tag(rom.relativePath)
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.12))
                    .cornerRadius(6)

                    // CPU and Model Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SYSTEM MODEL & CPU")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)

                        HStack(spacing: 16) {
                            SettingsPickerField(
                                title: "Amiga Model",
                                displayValue: emulatorModel,
                                selection: $emulatorModel
                            ) {
                                ForEach(models, id: \.self) { model in
                                    Text(model).tag(model)
                                }
                            }

                            SettingsPickerField(
                                title: "CPU Type",
                                displayValue: emulatorCpu,
                                selection: $emulatorCpu
                            ) {
                                ForEach(cpus, id: \.self) { cpu in
                                    Text(cpu).tag(cpu)
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.12))
                    .cornerRadius(6)

                    // RAM Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("MEMORY CONFIGURATION")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)

                        HStack(spacing: 16) {
                            SettingsPickerField(
                                title: "Chip RAM",
                                displayValue: emulatorChipRam,
                                selection: $emulatorChipRam
                            ) {
                                ForEach(chipRams, id: \.self) { ram in
                                    Text(ram).tag(ram)
                                }
                            }

                            SettingsPickerField(
                                title: "Fast RAM",
                                displayValue: emulatorFastRam,
                                selection: $emulatorFastRam
                            ) {
                                ForEach(fastRams, id: \.self) { ram in
                                    Text(ram).tag(ram)
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.12))
                    .cornerRadius(6)

                    // Emulation Tweaks
                    VStack(alignment: .leading, spacing: 12) {
                        Text("EMULATION FEATURES")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)

                        Toggle("Enable JIT (Just-In-Time) Compiler", isOn: $emulatorJit)
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
                            .foregroundColor(.white)
                            .font(.system(.body, design: .monospaced))

                        Toggle("Automatically Run in Native Emulator after Compilation", isOn: $autoRunEmulator)
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
                            .foregroundColor(.white)
                            .font(.system(.body, design: .monospaced))
                    }
                    .padding(12)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.12))
                    .cornerRadius(6)

                    // Custom CLI Arguments
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CUSTOM COMMAND LINE ARGUMENTS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)

                        Text("Append custom FS-UAE parameters for the FS-UAE backend.")
                            .font(.caption)
                            .foregroundColor(.gray)

                        TextField("--fullscreen", text: $emulatorCustomArgs)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(8)
                            .background(Color(red: 0.18, green: 0.18, blue: 0.22))
                            .cornerRadius(4)
                            .foregroundColor(.white)
                            .font(.system(.body, design: .monospaced))
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange.opacity(0.5), lineWidth: 1))
                    }
                    .padding(12)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.12))
                    .cornerRadius(6)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("VAMIGA RETROSHELL TRACE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)

                        Text("vAmiga executable")
                            .font(.caption)
                            .foregroundColor(.gray)

                        TextField("/Applications/vAmiga.app/Contents/MacOS/vAmiga", text: $vAmigaExecutablePath)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(8)
                            .background(Color(red: 0.18, green: 0.18, blue: 0.22))
                            .cornerRadius(4)
                            .foregroundColor(.white)
                            .font(.system(.body, design: .monospaced))
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange.opacity(0.5), lineWidth: 1))

                        Text("Additional vAmiga arguments")
                            .font(.caption)
                            .foregroundColor(.gray)

                        TextField("-\"help\"", text: $vAmigaCustomArgs)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(8)
                            .background(Color(red: 0.18, green: 0.18, blue: 0.22))
                            .cornerRadius(4)
                            .foregroundColor(.white)
                            .font(.system(.body, design: .monospaced))
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange.opacity(0.5), lineWidth: 1))
                    }
                    .padding(12)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.12))
                    .cornerRadius(6)
                }
                .padding(16)
            }

            // Footer Action buttons
            HStack {
                Spacer()
                Button(action: { isPresented = false }) {
                    Text("Save & Close")
                        .fontWeight(.bold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .foregroundColor(.black)
                        .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(16)
            .background(Color(red: 0.08, green: 0.08, blue: 0.1))
        }
        .frame(width: 500, height: 600)
        .background(Color(red: 0.05, green: 0.05, blue: 0.07))
        .foregroundColor(.white)
        .onAppear {
            self.availableRoms = EmulatorService.shared.getAvailableRoms()
            if !selectedRomFilename.isEmpty && !availableRoms.contains(where: { $0.relativePath == selectedRomFilename }) {
                selectedRomFilename = ""
            }
        }
    }
}

struct SettingsPickerField<SelectionValue: Hashable, Content: View>: View {
    let title: String
    let displayValue: String
    @Binding var selection: SelectionValue
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            ZStack {
                HStack(spacing: 8) {
                    Text(displayValue)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundColor(.orange.opacity(0.9))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color(red: 0.18, green: 0.18, blue: 0.22))
                .cornerRadius(4)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.orange.opacity(0.45), lineWidth: 1))

                Picker(title, selection: $selection) {
                    content()
                }
                .labelsHidden()
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.02)
            }
            .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ContentView()
}
