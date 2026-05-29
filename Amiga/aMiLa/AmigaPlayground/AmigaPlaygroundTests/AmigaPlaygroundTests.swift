import XCTest
import AppKit
@testable import AmigaPlayground

class AmigaPlaygroundTests: XCTestCase {
    private struct PromptBenchmark {
        let name: String
        let prompt: String
        let markers: [String]
    }

    private enum PromptEvalLevel: Int, CaseIterable {
        case level1 = 1
        case level2 = 2
        case level3 = 3

        var requiredPassRate: Double {
            switch self {
            case .level1, .level2:
                return 0.90
            case .level3:
                return 0.75
            }
        }
    }

    private struct PromptEvalCase {
        let level: PromptEvalLevel
        let name: String
        let prompt: String
        let expectedTemplateID: String
        let markers: [String]
        let expectsVisualEvidence: Bool
    }

    private struct PromptEvalResult {
        let evalCase: PromptEvalCase
        let templateID: String?
        let failures: [String]

        var passed: Bool {
            failures.isEmpty
        }
    }

    private var defaultPromptEvalCases: [PromptEvalCase] {
        PromptLibraryStore.defaultPrompts.map { item in
            let name = item.name
            let prompt = item.prompt
            let expectedID: String
            let markers: [String]
            let visual: Bool

            switch name {
            case "Demo 01 Copper Bars":
                expectedID = "static-copper-bars"
                markers = ["Static multi-color copper list demo.", "CopperList:"]
                visual = true
            case "Demo 02 Bouncing Copper Bars":
                expectedID = "bouncing-copper-bars"
                markers = ["Bouncing multi-color copper bars.", "Bar6Wait"]
                visual = true
            case "Demo 03 Raster Splits":
                expectedID = "raster-splits"
                markers = ["Raster split copper list template.", "CopperList:"]
                visual = true
            case "Demo 04 Sinusoidal Text Scroller":
                expectedID = "sinusoidal-text"
                markers = ["Sinusoidal scrolling text template.", "DrawSineText:", "SineOffsets:"]
                visual = true
            case "Demo 05 Starfield":
                expectedID = "starfield"
                markers = ["Starfield template.", "TwinkleStars:"]
                visual = true
            case "Demo 06 Hardware Sprite Motion":
                expectedID = "bouncing-sprite"
                markers = ["Bouncing sprite template.", "SpriteData:"]
                visual = true
            case "Demo 07 Blitter Bitplane Clear":
                expectedID = "blitter-clear"
                markers = ["Blitter clear screen hardware sample.", "$58(a6)"]
                visual = false
            case "Demo 08 Color-Cycling Logo":
                expectedID = "color-cycling-text"
                markers = ["Color-cycling text template.", "ColorTable:"]
                visual = true
            case "Demo 09 Double Buffered Bitplane":
                expectedID = "double-buffer-bitplane"
                markers = ["Double-buffered bitplane animation template.", "BufferA:", "BufferB:"]
                visual = true
            case "Demo 10 Frame-Synced Audio Intro":
                expectedID = "frame-synced-audio-intro"
                markers = ["Frame-synced audio intro loop template.", "$a0(a6)", "ColorTable:"]
                visual = true
            case "01 Minimal Executable":
                expectedID = "minimal-executable"
                markers = ["Minimal runnable AmigaDOS executable template.", "XDEF       _Start"]
                visual = false
            case "02 Background Color":
                expectedID = "background-color"
                markers = ["Background color hardware sample.", "$180(a6)"]
                visual = true
            case "03 VBlank Mouse Exit":
                expectedID = "wait-vblank-mouse-exit"
                markers = ["VBlank wait loop with left mouse exit sample.", "WaitVBlank:", "$bfe001"]
                visual = false
            case "04 Static Copper Bars":
                expectedID = "static-copper-bars"
                markers = ["Static multi-color copper list demo.", "CopperList:"]
                visual = true
            case "05 Bouncing Copper Bars":
                expectedID = "bouncing-copper-bars"
                markers = ["Bouncing multi-color copper bars.", "Bar6Wait"]
                visual = true
            case "06 Centered Fancy Text":
                expectedID = "centered-text"
                markers = ["Centered fancy text template.", "DrawCenteredText:"]
                visual = true
            case "07 Sinusoidal Text Scroll":
                expectedID = "sinusoidal-text"
                markers = ["Sinusoidal scrolling text template.", "DrawSineText:", "SineOffsets:"]
                visual = true
            case "08 Color-Cycling Logo":
                expectedID = "color-cycling-text"
                markers = ["Color-cycling text template.", "ColorTable:"]
                visual = true
            case "09 Bouncing Saucer Sprite":
                expectedID = "bouncing-sprite"
                markers = ["Bouncing sprite template.", "SpriteData:"]
                visual = true
            case "10 Starfield":
                expectedID = "starfield"
                markers = ["Starfield template.", "TwinkleStars:"]
                visual = true
            default:
                expectedID = ""
                markers = []
                visual = false
            }

            return PromptEvalCase(
                level: .level3,
                name: name,
                prompt: prompt,
                expectedTemplateID: expectedID,
                markers: markers,
                expectsVisualEvidence: visual
            )
        }
    }

    private var strategicEvalPrompts: [PromptEvalCase] {
        var cases: [PromptEvalCase] = []

        func add(
            _ level: PromptEvalLevel,
            _ name: String,
            _ prompts: [String],
            expectedTemplateID: String,
            markers: [String],
            expectsVisualEvidence: Bool
        ) {
            for prompt in prompts {
                cases.append(PromptEvalCase(
                    level: level,
                    name: name,
                    prompt: prompt,
                    expectedTemplateID: expectedTemplateID,
                    markers: markers,
                    expectsVisualEvidence: expectsVisualEvidence
                ))
            }
        }

        add(.level1, "minimal executable", [
            "generate a minimal Amiga program",
            "make the smallest amiga executable",
            "create an empty Amiga sample",
            "write a minimal executable sample",
            "produce a minimal program for Amiga",
            "give me the smallest Amiga program",
            "generate a minimal runnable sample",
            "make an empty executable for Amiga",
            "write the smallest executable sample",
            "create a minimal 68000 Amiga program"
        ], expectedTemplateID: "minimal-executable", markers: ["Minimal runnable AmigaDOS executable template.", "XDEF       _Start"], expectsVisualEvidence: false)

        add(.level1, "background color", [
            "set the screen background color to blue",
            "set background color to red",
            "make the background green",
            "screen colour cyan",
            "set colour purple for the screen",
            "set color orange for the display",
            "change the background to white",
            "make the screen color magenta",
            "set background to yellow",
            "screen color blue sample"
        ], expectedTemplateID: "background-color", markers: ["Background color hardware sample.", "$180(a6)"], expectsVisualEvidence: true)

        add(.level1, "vblank and mouse exit", [
            "write a wait loop that exits on left mouse click",
            "wait for vertical blank then exit on left mouse",
            "make a vblank loop",
            "wait for frame until mouse button",
            "stop when the left mouse button is pressed",
            "quit on mouse click after a wait loop",
            "wait for raster and exit on left mouse",
            "make a vertical blank wait sample",
            "loop until left mouse button",
            "wait for frame and quit on mouse click"
        ], expectedTemplateID: "wait-vblank-mouse-exit", markers: ["VBlank wait loop with left mouse exit sample.", "WaitVBlank:", "$bfe001"], expectsVisualEvidence: false)

        add(.level1, "input reader", [
            "read joystick input",
            "read mouse button",
            "make an input sample",
            "poll joystick and mouse button",
            "read joystick directions",
            "show a joystick input reader",
            "make a mouse button input test",
            "sample the joystick port",
            "read game controller input",
            "create an input polling routine"
        ], expectedTemplateID: "input-reader", markers: ["Joystick and mouse input reader sample.", "$0c(a6)", "$bfe001"], expectsVisualEvidence: false)

        add(.level2, "centered text", [
            #"write in the center with fancy font the words "hello""#,
            #"center the words "amiga rocks" with a fancy font"#,
            #"write centered text "ready" in yellow"#,
            #"make fancy font words "demo time" in the centre"#,
            #"put the words "code works" in the center"#,
            #"write text "system ok" with fancy font"#,
            #"center text "hello amiga""#,
            #"write in the centre of the screen the words "bootable""#,
            #"make a centered fancy text sample that says "pass""#,
            #"write the words "level two" in the center"#,
        ], expectedTemplateID: "centered-text", markers: ["Centered fancy text template.", "DrawCenteredText:"], expectsVisualEvidence: true)

        add(.level2, "static copper bars", [
            "generate static copper bars",
            "make copper bars",
            "draw static copper bands",
            "create a copper bar demo",
            "generate a tiny copper list demo",
            "make horizontal copper bands",
            "show six static copper bars",
            "generate a static multi color copper list",
            "make a copper stripe sample",
            "draw copper color bars"
        ], expectedTemplateID: "static-copper-bars", markers: ["Static multi-color copper list demo.", "CopperList:"], expectsVisualEvidence: true)

        add(.level2, "bouncing copper bars", [
            "generate bouncing copper bars",
            "make bouncing copper bands",
            "create slow bouncing copper bars",
            "generate fast bouncing copper bars",
            "bounce multi color copper bars",
            "make copper bars bounce vertically",
            "create horizontal bouncing copper bands",
            "generate bouncing multicolor copper bars",
            "make a copper bar bounce demo",
            "draw bouncing copper color bars"
        ], expectedTemplateID: "bouncing-copper-bars", markers: ["Bouncing multi-color copper bars.", "Bar6Wait"], expectsVisualEvidence: true)

        add(.level2, "blitter clear", [
            "clear the screen with the blitter",
            "make a blitter clear sample",
            "blit clear the bitplane",
            "use the blitter to clear memory",
            "write a blitter screen clear",
            "clear a screen buffer via blit",
            "generate blitter clear code",
            "make a hardware blitter clear demo",
            "use blitter D channel to clear the screen",
            "show a blit based clear routine"
        ], expectedTemplateID: "blitter-clear", markers: ["Blitter clear screen hardware sample.", "$58(a6)"], expectsVisualEvidence: false)

        add(.level2, "audio pulse", [
            "play a short audio beep",
            "make a Paula audio pulse",
            "generate a tone sample",
            "play a simple sound",
            "create audio channel zero beep",
            "make a short sound effect",
            "generate Paula channel 0 audio",
            "write a beep using audio DMA",
            "play a quick tone",
            "make an audio pulse demo"
        ], expectedTemplateID: "audio-pulse", markers: ["Paula audio channel 0 pulse sample.", "$a0(a6)", "$a8(a6)"], expectsVisualEvidence: false)

        add(.level3, "starfield", [
            "generate a starfield demo",
            "make a fast starfield",
            "create a star field effect",
            "draw twenty moving stars",
            "make a scrolling starfield",
            "generate a slow starfield sample",
            "show a starfield with twinkle",
            "create a deep space star field",
            "make fast stars on a black background",
            "generate twenty bright stars"
        ], expectedTemplateID: "starfield", markers: ["Starfield template.", "TwinkleStars:"], expectsVisualEvidence: true)

        add(.level3, "bouncing sprite", [
            "generate a bouncing sprite object",
            "make a slow bouncing saucer sprite",
            "create a bouncing ball sprite",
            "make a sprite bounce vertically",
            "generate a bouncing ufo object",
            "draw a bouncing ship sprite",
            "make an object bounce on screen",
            "create a fast bouncing sprite",
            "generate a sprite object bouncing horizontally",
            "show a bouncing saucer object"
        ], expectedTemplateID: "bouncing-sprite", markers: ["Bouncing sprite template.", "SpriteData:"], expectsVisualEvidence: true)

        add(.level3, "sinusoidal scrolling text", [
            #"make the words "flying saucer" scroll across the screen in a sinusoidal pattern"#,
            #"scroll text "hello amiga" in a sine wave"#,
            #"make the words "demo scene" scroll left with sinus motion"#,
            #"write text "wave rider" scrolling in a sine pattern"#,
            #"make the words "space run" scroll with sinusoidal motion"#,
            #"scroll the words "amiga forever" across in a sine wave"#,
            #"create sine scrolling text "level three""#,
            #"make text "ship incoming" scroll sinusoidally"#,
            #"write the words "flying saucer" scrolling with sine motion"#,
            #"scroll text "copper dreams" across the screen in a sinus pattern"#
        ], expectedTemplateID: "sinusoidal-text", markers: ["Sinusoidal scrolling text template.", "DrawSineText:", "SineOffsets:"], expectsVisualEvidence: true)

        add(.level3, "color cycling text", [
            #"make a color-cycling logo that says "amiga""#,
            #"make a fast blue color-cycling logo that says "amiga""#,
            #"write color cycling text "demo""#,
            #"create a colour-cycling logo that says "intro""#,
            #"make color cycling words "hello""#,
            #"write a centered color-cycling text "shine""#,
            #"make a colour cycling logo saying "ocs""#,
            #"generate color-cycling text "bright""#,
            #"create a fast color cycling logo "amila""#,
            #"make color cycling text that says "done""#
        ], expectedTemplateID: "color-cycling-text", markers: ["Color-cycling text template.", "ColorTable:"], expectsVisualEvidence: true)

        return cases
    }

    private var goal2BenchmarkPrompts: [PromptBenchmark] {
        [
            PromptBenchmark(
                name: "static copper bars",
                prompt: "generate static copper bars",
                markers: ["Static multi-color copper list demo.", "CopperList:", "$0180,$0f00"]
            ),
            PromptBenchmark(
                name: "bouncing copper bars",
                prompt: "generate bouncing copper bars",
                markers: ["Bouncing multi-color copper bars.", "Bar6Wait", "btst       #6,$bfe001"]
            ),
            PromptBenchmark(
                name: "starfield",
                prompt: "generate a starfield demo",
                markers: ["Starfield template.", "Effect: starfield", "StarOffsets:", "TwinkleStars:"]
            ),
            PromptBenchmark(
                name: "bouncing sprite object",
                prompt: "generate a bouncing sprite object",
                markers: ["Bouncing sprite template.", "Effect: bouncing sprite object", "SpriteData:", "$120(a5)", "$0000,$0000"]
            ),
            PromptBenchmark(
                name: "color-cycling logo",
                prompt: #"make a color-cycling logo that says "amiga""#,
                markers: ["Color-cycling text template.", "Requested text: amiga", #"dc.b       "AMIGA",0"#, "ColorTable:", "TextColor:"]
            ),
            PromptBenchmark(
                name: "sinusoidal flying saucer text",
                prompt: #"make the words "flying saucer" scroll across the screen in a sinusoidal patternmake the words "flying saucer" scroll across the screen in a sinusoidal pattern"#,
                markers: ["Sinusoidal scrolling text template.", "Requested text: flying saucer", #"dc.b       "FLYING SAUCER",0"#, "DrawSineText:", "SineOffsets:", "ScrollX:"]
            ),
            PromptBenchmark(
                name: "centered flying saucer text",
                prompt: "write in the center of the screen with fancy font the words “flying saucer”",
                markers: ["Centered fancy text template.", "Requested text: flying saucer", #"dc.b       "FLYING SAUCER",0"#, "DrawCenteredText:", "GlyphF:"]
            )
        ]
    }

    func testChatBoingBallPreferenceDefaultsVisible() {
        XCTAssertEqual(AppPreferenceDefaults.showChatBoingBallKey, "showChatBoingBall")
        XCTAssertTrue(AppPreferenceDefaults.showChatBoingBall)
    }

    func testAutoInjectGeneratedCodePreferenceDefaultsOn() {
        XCTAssertEqual(AppPreferenceDefaults.autoInjectGeneratedCodeKey, "autoInjectGeneratedCode")
        XCTAssertTrue(AppPreferenceDefaults.autoInjectGeneratedCode)
    }

    @MainActor
    func testPromptLibrarySeedsIncreasinglyComplexDefaultPrompts() {
        let suiteName = "PromptLibraryDefaults-\(UUID().uuidString)"
        let defaults = try! XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = PromptLibraryStore(userDefaults: defaults)

        XCTAssertEqual(store.prompts.count, 20)
        XCTAssertEqual(store.prompts.map(\.name), [
            "Demo 01 Copper Bars",
            "Demo 02 Bouncing Copper Bars",
            "Demo 03 Raster Splits",
            "Demo 04 Sinusoidal Text Scroller",
            "Demo 05 Starfield",
            "Demo 06 Hardware Sprite Motion",
            "Demo 07 Blitter Bitplane Clear",
            "Demo 08 Color-Cycling Logo",
            "Demo 09 Double Buffered Bitplane",
            "Demo 10 Frame-Synced Audio Intro",
            "01 Minimal Executable",
            "02 Background Color",
            "03 VBlank Mouse Exit",
            "04 Static Copper Bars",
            "05 Bouncing Copper Bars",
            "06 Centered Fancy Text",
            "07 Sinusoidal Text Scroll",
            "08 Color-Cycling Logo",
            "09 Bouncing Saucer Sprite",
            "10 Starfield"
        ])
        XCTAssertTrue(store.prompts[0].prompt.contains("static copper bars"))
        XCTAssertTrue(store.prompts[2].prompt.contains("raster split"))
        XCTAssertTrue(store.prompts[8].prompt.contains("double-buffered"))
        XCTAssertTrue(store.prompts[9].prompt.contains("Paula audio"))
    }

    @MainActor
    func testPromptLibraryMergesDefaultsWithExistingPromptsOnce() {
        let suiteName = "PromptLibraryMerge-\(UUID().uuidString)"
        let defaults = try! XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let customPrompt = PromptLibraryItem(
            name: "Custom Saved Prompt",
            prompt: "Generate an audio DMA routine with clear register setup.",
            createdAt: Date(timeIntervalSinceReferenceDate: 2_000_000),
            updatedAt: Date(timeIntervalSinceReferenceDate: 2_000_000)
        )
        let encoded = try! JSONEncoder().encode([customPrompt])
        defaults.set(encoded, forKey: "promptLibraryItems")

        let seededStore = PromptLibraryStore(userDefaults: defaults)
        XCTAssertEqual(seededStore.prompts.count, 21)
        XCTAssertTrue(seededStore.prompts.contains(where: { $0.name == "Custom Saved Prompt" }))
        XCTAssertTrue(seededStore.prompts.contains(where: { $0.name == "Demo 10 Frame-Synced Audio Intro" }))

        let promptToDelete = try! XCTUnwrap(seededStore.prompts.first { $0.name == "01 Minimal Executable" })
        seededStore.deletePrompt(id: promptToDelete.id)

        let reloadedStore = PromptLibraryStore(userDefaults: defaults)
        XCTAssertEqual(reloadedStore.prompts.count, 20)
        XCTAssertFalse(reloadedStore.prompts.contains(where: { $0.name == "01 Minimal Executable" }))
        XCTAssertTrue(reloadedStore.prompts.contains(where: { $0.name == "Custom Saved Prompt" }))
    }

    // MARK: - Assistant Chat Session Tests

    func testAssistantChatSessionSubmitsPromptOnceAndIgnoresDuplicateWhileGenerating() {
        let session = AssistantChatSession()
        let prompt = "build an animated copper list"

        let firstRequest = session.submit(prompt)
        let duplicateRequest = session.submit(prompt)

        XCTAssertNotNil(firstRequest)
        XCTAssertNil(duplicateRequest)
        XCTAssertTrue(session.isGenerating)
        XCTAssertEqual(session.messages.map(\.role), ["user"])
        XCTAssertEqual(session.messages.map(\.content), [prompt])
        XCTAssertEqual(firstRequest?.messages.map(\.content), [prompt])
    }

    func testAssistantChatSessionDoesNotAppendBlankAssistantBubbleForEmptyCompletion() {
        let session = AssistantChatSession()
        _ = session.submit("build an animated copper list")

        let result = session.complete(fullResponse: "", streamedResponse: "")

        XCTAssertNil(result.injectedCode)
        XCTAssertFalse(session.isGenerating)
        XCTAssertEqual(session.messages.count, 2)
        XCTAssertEqual(session.messages[0].role, "user")
        XCTAssertEqual(session.messages[1].role, "assistant")
        XCTAssertFalse(session.messages[1].content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        XCTAssertTrue(session.messages[1].content.contains("No response text"))
    }

    func testAssistantChatSessionExtractsGeneratedCodeForEditorInjection() {
        let session = AssistantChatSession()
        _ = session.submit("build an animated copper list")

        let response = """
        Here is the generated copper list:

        ```asm
        SECTION Code,CODE,CHIP
        CopperList:
            dc.w $180,$00f
            dc.w $ffff,$fffe
        ```
        """

        let result = session.complete(fullResponse: response, streamedResponse: "")

        XCTAssertFalse(session.isGenerating)
        XCTAssertEqual(session.messages.map(\.role), ["user", "assistant"])
        XCTAssertEqual(result.injectedCode, """
            SECTION Code,CODE,CHIP
CopperList:
    dc.w $180,$00f
    dc.w $ffff,$fffe
""")
        XCTAssertEqual(result.consoleMessage, "Injected code block from Amiga Assistant.")
    }

    func testAssistantChatSessionStoresTokenUsageOnAssistantMessage() {
        let session = AssistantChatSession()
        _ = session.submit("build an animated copper list")
        let tokenUsage = TokenUsage(inputTokens: 12, outputTokens: 34, totalTokens: 46)

        _ = session.complete(
            fullResponse: "Generated answer",
            streamedResponse: "",
            tokenUsage: tokenUsage
        )

        XCTAssertEqual(session.messages.last?.tokenUsage, tokenUsage)
        XCTAssertEqual(session.messages.last?.tokenUsage?.displayText, "Tokens: in 12 / out 34 / total 46")
    }

    func testAssistantChatSessionAllowsAssistantMessageWithoutTokenUsage() {
        let session = AssistantChatSession()
        _ = session.submit("build an animated copper list")

        _ = session.complete(fullResponse: "Generated answer", streamedResponse: "")

        XCTAssertEqual(session.messages.last?.role, "assistant")
        XCTAssertNil(session.messages.last?.tokenUsage)
    }

    func testAssistantChatSessionUsesStreamedResponseWhenCompletionBodyIsEmpty() {
        let session = AssistantChatSession()
        _ = session.submit("build an animated copper list")
        session.appendChunk("SECTION Code,CODE,CHIP\n")
        session.appendChunk("CopperList:\n    dc.w $ffff,$fffe")

        let result = session.complete(fullResponse: "", streamedResponse: session.currentGeneration)

        XCTAssertEqual(session.messages.count, 2)
        XCTAssertEqual(session.messages[1].content, "SECTION Code,CODE,CHIP\nCopperList:\n    dc.w $ffff,$fffe")
        XCTAssertEqual(result.injectedCode, "            SECTION Code,CODE,CHIP\nCopperList:\n    dc.w $ffff,$fffe")
    }

    func testAssistantChatSessionHandlesEmptyContentWithReasoningGracefully() {
        let session = AssistantChatSession()
        _ = session.submit("build an animated copper list")
        session.appendReasoningChunk("Thinking about copper lists...")
        session.appendReasoningChunk(" Deciding to output later.")

        let result = session.complete(fullResponse: "", streamedResponse: "")

        XCTAssertEqual(session.messages.count, 2)
        XCTAssertTrue(session.messages[1].content.contains("Thinking process completed, but no clean code"))
        XCTAssertEqual(session.messages[1].reasoning, "Thinking about copper lists... Deciding to output later.")
        XCTAssertNil(result.injectedCode)
        XCTAssertNil(result.consoleMessage)
    }

    func testAssistantChatSessionExtractsCodeWhenProviderReturnsReasoningOnly() {
        let session = AssistantChatSession()
        _ = session.submit("generate a bouncing multi color copper list")

        let reasoning = """
        ```assembly
        SECTION Code,CODE,CHIP
        CopperList:
            dc.w $5007,$fffe,$0180,$0f00
            dc.w $ffff,$fffe
        ```
        """

        let result = session.complete(fullResponse: "", streamedResponse: "", reasoningResponse: reasoning)

        XCTAssertEqual(result.injectedCode, """
            SECTION Code,CODE,CHIP
CopperList:
    dc.w $5007,$fffe,$0180,$0f00
    dc.w $ffff,$fffe
""")
        XCTAssertEqual(result.consoleMessage, "Injected code block from Amiga Assistant.")
        XCTAssertTrue(session.messages[1].content.contains("CopperList"))
        XCTAssertEqual(session.messages[1].reasoning, reasoning)
    }

    func testAssistantPromptTemplateMatchesBouncingMulticolorCopperList() {
        let source = AssistantPromptTemplate.source(for: "generate a bouncing multi color copper list")

        XCTAssertNotNil(source)
        XCTAssertTrue(source?.contains("CopperList:") == true)
        XCTAssertTrue(source?.contains("Bar6Wait") == true)
        XCTAssertFalse(source?.contains("COLOR_A") == true)
        XCTAssertFalse(source?.contains("WAIT (") == true)
    }

    func testAssistantPromptTemplateBouncingMulticolorCopperListCompiles() {
        let compiler = CompilerService.shared
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            print("Skipping prompt template compilation test: VASM compiler not found at \(compiler.vasmPath)")
            return
        }

        let source = try! XCTUnwrap(AssistantPromptTemplate.source(for: "generate a bouncing multi color copper list"))
        let expectation = self.expectation(description: "Bouncing multicolor copper list template compiles")

        compiler.compile(assemblyCode: source) { success, output in
            XCTAssertTrue(success, "Prompt template compilation failed:\n\(output)")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)
    }

    func testAssistantPromptTemplateMatchesStaticCopperList() {
        let source = AssistantPromptTemplate.source(for: "generate a static copper list demo")

        XCTAssertNotNil(source)
        XCTAssertTrue(source?.contains("CopperList:") == true)
        XCTAssertTrue(source?.contains("$80(a6)") == true)
        XCTAssertFalse(source?.contains("dff000(a6)") == true)
        XCTAssertFalse(source?.contains("dec.l") == true)
    }

    func testAssistantPromptTemplateStaticCopperListCompiles() {
        let compiler = CompilerService.shared
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            print("Skipping static copper template compilation test: VASM compiler not found at \(compiler.vasmPath)")
            return
        }

        let source = try! XCTUnwrap(AssistantPromptTemplate.source(for: "generate a static copper list demo"))
        let expectation = self.expectation(description: "Static copper list template compiles")

        compiler.compile(assemblyCode: source) { success, output in
            XCTAssertTrue(success, "Static copper list template compilation failed:\n\(output)")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)
    }

    func testAssistantPromptTemplateMatchesSinusoidalFlyingSaucerText() {
        let source = AssistantPromptTemplate.source(for: #"make the words "flying saucer" scroll across the screen in a sinusoidal patternmake the words "flying saucer" scroll across the screen in a sinusoidal pattern"#)

        XCTAssertNotNil(source)
        XCTAssertTrue(source?.contains("Requested text: flying saucer") == true)
        XCTAssertTrue(source?.contains("TextString:") == true)
        XCTAssertTrue(source?.contains(#"dc.b       "FLYING SAUCER",0"#) == true)
        XCTAssertTrue(source?.contains("DrawSineText:") == true)
        XCTAssertTrue(source?.contains("SineOffsets:") == true)
        XCTAssertTrue(source?.contains("ScrollX:") == true)
    }

    func testAssistantPromptTemplateSinusoidalFlyingSaucerTextCompiles() {
        let compiler = CompilerService.shared
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            print("Skipping sinusoidal text template compilation test: VASM compiler not found at \(compiler.vasmPath)")
            return
        }

        let source = try! XCTUnwrap(AssistantPromptTemplate.source(for: #"make the words "flying saucer" scroll across the screen in a sinusoidal patternmake the words "flying saucer" scroll across the screen in a sinusoidal pattern"#))
        let expectation = self.expectation(description: "Sinusoidal flying saucer text template compiles")

        compiler.compile(assemblyCode: source) { success, output in
            XCTAssertTrue(success, "Sinusoidal text template compilation failed:\n\(output)")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)
    }

    func testAssistantPromptTemplateMatchesCenteredFancyFlyingSaucerText() {
        let source = AssistantPromptTemplate.source(for: "write in the center of the screen with fancy font the words “flying saucer”")

        XCTAssertNotNil(source)
        XCTAssertTrue(source?.contains("Requested text: flying saucer") == true)
        XCTAssertTrue(source?.contains("TextString:") == true)
        XCTAssertTrue(source?.contains(#"dc.b       "FLYING SAUCER",0"#) == true)
        XCTAssertTrue(source?.contains("DrawCenteredText:") == true)
        XCTAssertTrue(source?.contains("GlyphF:") == true)
        XCTAssertTrue(source?.contains(".hold:") == true)
    }

    func testAssistantPromptTemplateCenteredFancyFlyingSaucerTextCompiles() {
        let compiler = CompilerService.shared
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            print("Skipping centered text template compilation test: VASM compiler not found at \(compiler.vasmPath)")
            return
        }

        let source = try! XCTUnwrap(AssistantPromptTemplate.source(for: "write in the center of the screen with fancy font the words “flying saucer”"))
        let expectation = self.expectation(description: "Centered flying saucer text template compiles")

        compiler.compile(assemblyCode: source) { success, output in
            XCTAssertTrue(success, "Centered text template compilation failed:\n\(output)")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)
    }

    func testAssistantPromptTemplateFlyingSaucerTextTemplatesGenerateBootableADFs() {
        let compiler = CompilerService.shared
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            print("Skipping flying saucer ADF generation test: VASM compiler not found at \(compiler.vasmPath)")
            return
        }
        guard FileManager.default.fileExists(atPath: compiler.xdftoolPath) else {
            print("Skipping flying saucer ADF generation test: xdftool not found at \(compiler.xdftoolPath)")
            return
        }

        let cases = [
            ("sine", #"make the words "flying saucer" scroll across the screen in a sinusoidal patternmake the words "flying saucer" scroll across the screen in a sinusoidal pattern"#),
            ("centered", "write in the center of the screen with fancy font the words “flying saucer”")
        ]

        for testCase in cases {
            let source = try! XCTUnwrap(AssistantPromptTemplate.source(for: testCase.1))
            let targetADF = FileManager.default.temporaryDirectory
                .appendingPathComponent("flying_saucer_\(testCase.0)_\(UUID().uuidString).adf")
            let expectation = self.expectation(description: "\(testCase.0) flying saucer text template generates bootable ADF")

            compiler.generateBootableADF(assemblyCode: source, targetADFPath: targetADF.path) { success, output in
                XCTAssertTrue(success, "\(testCase.0) flying saucer ADF generation failed:\n\(output)")
                XCTAssertTrue(FileManager.default.fileExists(atPath: targetADF.path))
                if let attributes = try? FileManager.default.attributesOfItem(atPath: targetADF.path),
                   let size = attributes[.size] as? NSNumber {
                    XCTAssertGreaterThan(size.intValue, 0)
                } else {
                    XCTFail("Could not read generated ADF size for \(testCase.0)")
                }
                try? FileManager.default.removeItem(at: targetADF)
                expectation.fulfill()
            }

            waitForExpectations(timeout: 10.0)
        }
    }

    func testAssistantPromptTemplateFlyingSaucerTextTemplatesPassSemanticGate() {
        let cases = [
            #"make the words "flying saucer" scroll across the screen in a sinusoidal patternmake the words "flying saucer" scroll across the screen in a sinusoidal pattern"#,
            "write in the center of the screen with fancy font the words “flying saucer”"
        ]

        for prompt in cases {
            let source = try! XCTUnwrap(AssistantPromptTemplate.source(for: prompt))
            let result = AssemblySemanticValidator.validate(source: source, prompt: prompt)

            XCTAssertTrue(result.passed, "Flying saucer text template should pass semantic gate for prompt:\n\(prompt)\nFailures:\n\(result.summary)")
        }
    }

    func testAssistantPromptTemplateGoal2BenchmarkPromptsClassifyAndContainParameters() {
        for benchmark in goal2BenchmarkPrompts {
            let source = AssistantPromptTemplate.source(for: benchmark.prompt)

            XCTAssertNotNil(source, "\(benchmark.name) should route to a deterministic template")
            for marker in benchmark.markers {
                XCTAssertTrue(source?.contains(marker) == true, "\(benchmark.name) should contain marker \(marker)")
            }
        }
    }

    func testAssistantPromptTemplateGoal2BenchmarkPromptsCompile() {
        let compiler = CompilerService.shared
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            print("Skipping Goal 2 benchmark compilation test: VASM compiler not found at \(compiler.vasmPath)")
            return
        }

        for benchmark in goal2BenchmarkPrompts {
            let source = try! XCTUnwrap(AssistantPromptTemplate.source(for: benchmark.prompt))
            let expectation = self.expectation(description: "\(benchmark.name) compiles")

            compiler.compile(assemblyCode: source) { success, output in
                XCTAssertTrue(success, "\(benchmark.name) compilation failed:\n\(output)")
                expectation.fulfill()
            }

            waitForExpectations(timeout: 5.0)
        }
    }

    func testAssistantPromptTemplateGoal2BenchmarkPromptsGenerateBootableADFs() {
        let compiler = CompilerService.shared
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            print("Skipping Goal 2 benchmark ADF generation test: VASM compiler not found at \(compiler.vasmPath)")
            return
        }
        guard FileManager.default.fileExists(atPath: compiler.xdftoolPath) else {
            print("Skipping Goal 2 benchmark ADF generation test: xdftool not found at \(compiler.xdftoolPath)")
            return
        }

        for benchmark in goal2BenchmarkPrompts {
            let source = try! XCTUnwrap(AssistantPromptTemplate.source(for: benchmark.prompt))
            let safeName = benchmark.name.replacingOccurrences(of: " ", with: "_")
            let targetADF = FileManager.default.temporaryDirectory
                .appendingPathComponent("goal2_\(safeName)_\(UUID().uuidString).adf")
            let expectation = self.expectation(description: "\(benchmark.name) generates bootable ADF")

            compiler.generateBootableADF(assemblyCode: source, targetADFPath: targetADF.path) { success, output in
                XCTAssertTrue(success, "\(benchmark.name) ADF generation failed:\n\(output)")
                XCTAssertTrue(FileManager.default.fileExists(atPath: targetADF.path))
                if let attributes = try? FileManager.default.attributesOfItem(atPath: targetADF.path),
                   let size = attributes[.size] as? NSNumber {
                    XCTAssertGreaterThan(size.intValue, 0)
                } else {
                    XCTFail("Could not read generated ADF size for \(benchmark.name)")
                }
                try? FileManager.default.removeItem(at: targetADF)
                expectation.fulfill()
            }

            waitForExpectations(timeout: 10.0)
        }
    }

    func testAssistantPromptTemplateGoal2BenchmarkPromptsPassSemanticGate() {
        for benchmark in goal2BenchmarkPrompts {
            let source = try! XCTUnwrap(AssistantPromptTemplate.source(for: benchmark.prompt))
            let result = AssemblySemanticValidator.validate(source: source, prompt: benchmark.prompt)

            XCTAssertTrue(result.passed, "\(benchmark.name) should pass semantic gate. Failures:\n\(result.summary)")
        }
    }

    func testAssistantPromptTemplateMetadataAndFallbackPolicy() {
        let match = AssistantPromptTemplate.match(for: #"make a fast blue color-cycling logo that says "amiga""#)

        XCTAssertEqual(match?.id, "color-cycling-text")
        XCTAssertEqual(match?.name, "Color-cycling text")
        XCTAssertEqual(match?.parameters["text"], "amiga")
        XCTAssertEqual(match?.parameters["color"], "blue")
        XCTAssertEqual(match?.parameters["mode"], "centered")
        XCTAssertEqual(match?.parameters["speed"], "fast")
        XCTAssertTrue(match?.consoleSummary.contains("Using template: Color-cycling text") == true)
        XCTAssertTrue(match?.consoleSummary.contains("Text: amiga") == true)
        XCTAssertTrue(match?.consoleSummary.contains("Color: blue") == true)
        XCTAssertTrue(match?.consoleSummary.contains("Mode: centered") == true)
        XCTAssertTrue(match?.consoleSummary.contains("Speed: fast") == true)

        let fallback = AssistantPromptTemplate.fallbackMessage(for: "write a ray traced text teapot demo")
        XCTAssertTrue(fallback.contains("No deterministic template matched"))
        XCTAssertTrue(fallback.contains("Using model generation"))
        XCTAssertTrue(fallback.contains("may still need repair"))
        XCTAssertTrue(fallback.contains("Nearest supported templates: Centered text, Sinusoidal text, Color-cycling text."))
    }

    func testAssistantPromptTemplateExtractsGeneralizedParameters() {
        let sine = AssistantPromptTemplate.match(for: #"make the words "flying saucer" scroll left across the screen in a slow sinusoidal pattern"#)
        XCTAssertEqual(sine?.id, "sinusoidal-text")
        XCTAssertEqual(sine?.parameters["text"], "flying saucer")
        XCTAssertEqual(sine?.parameters["mode"], "scrolling")
        XCTAssertEqual(sine?.parameters["direction"], "left")
        XCTAssertEqual(sine?.parameters["speed"], "slow")

        let centered = AssistantPromptTemplate.match(for: "write in the center of the screen with fancy font the words “flying saucer”")
        XCTAssertEqual(centered?.id, "centered-text")
        XCTAssertEqual(centered?.parameters["text"], "flying saucer")
        XCTAssertEqual(centered?.parameters["mode"], "centered")
        XCTAssertEqual(centered?.parameters["position"], "center")
        XCTAssertEqual(centered?.parameters["font"], "bitmap fancy")

        let stars = AssistantPromptTemplate.match(for: "generate a fast starfield with twenty stars")
        XCTAssertEqual(stars?.id, "starfield")
        XCTAssertEqual(stars?.parameters["mode"], "scrolling")
        XCTAssertEqual(stars?.parameters["stars"], "20")
        XCTAssertEqual(stars?.parameters["speed"], "fast")

        let bars = AssistantPromptTemplate.match(for: "generate bouncing copper bars: 12 moving horizontal fast")
        XCTAssertEqual(bars?.id, "bouncing-copper-bars")
        XCTAssertEqual(bars?.parameters["mode"], "bouncing")
        XCTAssertEqual(bars?.parameters["bars"], "12")
        XCTAssertEqual(bars?.parameters["direction"], "horizontal")
        XCTAssertEqual(bars?.parameters["speed"], "fast")

        let sprite = AssistantPromptTemplate.match(for: "generate a slow bouncing saucer sprite moving vertical")
        XCTAssertEqual(sprite?.id, "bouncing-sprite")
        XCTAssertEqual(sprite?.parameters["mode"], "bouncing")
        XCTAssertEqual(sprite?.parameters["object"], "saucer")
        XCTAssertEqual(sprite?.parameters["direction"], "vertical")
        XCTAssertEqual(sprite?.parameters["speed"], "slow")
    }

    func testAssistantPromptTemplateRoutesBasicSamplesAwayFromModelFallback() {
        let cases: [(prompt: String, id: String, name: String, markers: [String])] = [
            (
                "generate a minimal Amiga program",
                "minimal-executable",
                "Minimal executable",
                ["Minimal runnable AmigaDOS executable template.", "XDEF       _Start", "_Start:"]
            ),
            (
                "set the screen background color to blue",
                "background-color",
                "Background color",
                ["Background color hardware sample.", "$100(a6)", "$180(a6)", "Bitplane:"]
            ),
            (
                "clear the screen with the blitter",
                "blitter-clear",
                "Blitter clear",
                ["Blitter clear screen hardware sample.", "$40(a6)", "$58(a6)", ".waitAfter:"]
            ),
            (
                "play a short audio beep",
                "audio-pulse",
                "Audio pulse",
                ["Paula audio channel 0 pulse sample.", "$a0(a6)", "$a4(a6)", "$a8(a6)"]
            ),
            (
                "write a wait loop that exits on left mouse click",
                "wait-vblank-mouse-exit",
                "VBlank mouse exit",
                ["VBlank wait loop with left mouse exit sample.", "WaitVBlank:", "$bfe001"]
            ),
            (
                "read joystick input",
                "input-reader",
                "Input reader",
                ["Joystick and mouse input reader sample.", "$0c(a6)", "$bfe001"]
            )
        ]

        for testCase in cases {
            let match = AssistantPromptTemplate.match(for: testCase.prompt)
            XCTAssertEqual(match?.id, testCase.id, "\(testCase.prompt) should route to a deterministic basic template")
            XCTAssertEqual(match?.name, testCase.name)
            XCTAssertTrue(match?.consoleSummary.contains("Using template: \(testCase.name)") == true)
            for marker in testCase.markers {
                XCTAssertTrue(match?.source.contains(marker) == true, "\(testCase.name) should contain marker \(marker)")
            }
        }
    }

    func testAssistantPromptTemplateBasicSamplesPassSemanticGate() {
        let prompts = [
            "generate a minimal Amiga program",
            "set the screen background color to blue",
            "clear the screen with the blitter",
            "play a short audio beep",
            "write a wait loop that exits on left mouse click",
            "read joystick input"
        ]

        for prompt in prompts {
            let source = try! XCTUnwrap(AssistantPromptTemplate.source(for: prompt))
            let result = AssemblySemanticValidator.validate(source: source, prompt: prompt)

            XCTAssertTrue(result.passed, "\(prompt) should pass semantic gate. Failures:\n\(result.summary)")
        }
    }

    func testAssistantPromptTemplateBasicSamplesCompile() {
        let compiler = CompilerService.shared
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            print("Skipping basic sample template compilation test: VASM compiler not found at \(compiler.vasmPath)")
            return
        }

        let prompts = [
            "generate a minimal Amiga program",
            "set the screen background color to blue",
            "clear the screen with the blitter",
            "play a short audio beep",
            "write a wait loop that exits on left mouse click",
            "read joystick input"
        ]

        for prompt in prompts {
            let source = try! XCTUnwrap(AssistantPromptTemplate.source(for: prompt))
            let expectation = self.expectation(description: "\(prompt) compiles")

            compiler.compile(assemblyCode: source) { success, output in
                XCTAssertTrue(success, "\(prompt) compilation failed:\n\(output)")
                expectation.fulfill()
            }

            waitForExpectations(timeout: 5.0)
        }
    }

    func testStrategicEvalSuiteDefinesLevelOneThroughThreeCoverage() {
        let prompts = strategicEvalPrompts

        XCTAssertEqual(prompts.count, 130)
        XCTAssertEqual(prompts.filter { $0.level == .level1 }.count, 40)
        XCTAssertEqual(prompts.filter { $0.level == .level2 }.count, 50)
        XCTAssertEqual(prompts.filter { $0.level == .level3 }.count, 40)
        XCTAssertEqual(Set(prompts.map(\.prompt)).count, prompts.count)
        XCTAssertTrue(prompts.allSatisfy { !$0.markers.isEmpty })
    }

    func testStrategicEvalSuiteRoutesLevelOneThroughThreePromptsAtTargetPassRates() {
        let results = strategicEvalPrompts.map { evalCase in
            routeAndMarkerResult(for: evalCase)
        }

        assertStrategicPassRates(results, context: "routing and marker coverage")
    }

    func testStrategicEvalSuiteToolchainPassRatesForLevelOneThroughThreePrompts() throws {
        let results = try evaluateStrategicToolchainCases(strategicEvalPrompts)
        let reportURL = try writeStrategicEvalReport(results, suffix: "toolchain")

        print("Strategic eval report: \(reportURL.path)")
        assertStrategicPassRates(results, context: "semantic + compile + ADF + expected visual coverage")
    }

    func testStrategicEvalSuiteVAmigaRuntimePassRatesWhenEnabled() throws {
        let enableFlagPath = FileManager.default.temporaryDirectory.appendingPathComponent("AMIGA_RUN_STRATEGIC_VAMIGA_SMOKE").path
        let globalEnableFlagPath = "/private/tmp/AMIGA_RUN_STRATEGIC_VAMIGA_SMOKE"
        let isEnabled = ProcessInfo.processInfo.environment["AMIGA_RUN_STRATEGIC_VAMIGA_SMOKE"] == "1"
            || FileManager.default.fileExists(atPath: enableFlagPath)
            || FileManager.default.fileExists(atPath: globalEnableFlagPath)
        guard isEnabled else {
            throw XCTSkip("Set AMIGA_RUN_STRATEGIC_VAMIGA_SMOKE=1 or create \(globalEnableFlagPath) to run full strategic vAmiga runtime pass-rate validation.")
        }

        let results = try evaluateStrategicVAmigaRuntimeCases(strategicEvalPrompts)
        let reportURL = try writeStrategicEvalReport(results, suffix: "vamiga-runtime")

        print("Strategic vAmiga runtime eval report: \(reportURL.path)")
        assertStrategicPassRates(results, context: "semantic + compile + ADF + vAmiga runtime frame coverage")
    }

    func testDefaultPromptLibraryPromptsRouteAndCompile() throws {
        let results = try evaluateStrategicToolchainCases(defaultPromptEvalCases)
        let reportURL = try writeStrategicEvalReport(results, suffix: "default-prompts-toolchain")

        print("Default prompt toolchain eval report: \(reportURL.path)")
        XCTAssertTrue(results.allSatisfy(\.passed), defaultPromptFailureSummary(results))
    }

    func testDefaultPromptLibraryPromptsRunInVAmigaWhenEnabled() throws {
        let enableFlagPath = FileManager.default.fileExists(atPath: FileManager.default.temporaryDirectory.appendingPathComponent("AMIGA_RUN_DEFAULT_PROMPT_VAMIGA_SMOKE").path)
        let globalEnableFlagPath = FileManager.default.fileExists(atPath: "/private/tmp/AMIGA_RUN_DEFAULT_PROMPT_VAMIGA_SMOKE")
        let isEnabled = ProcessInfo.processInfo.environment["AMIGA_RUN_DEFAULT_PROMPT_VAMIGA_SMOKE"] == "1" || enableFlagPath || globalEnableFlagPath
        guard isEnabled else {
            throw XCTSkip("Set AMIGA_RUN_DEFAULT_PROMPT_VAMIGA_SMOKE=1 or create /private/tmp/AMIGA_RUN_DEFAULT_PROMPT_VAMIGA_SMOKE to run default prompt vAmiga validation.")
        }

        let results = try evaluateStrategicVAmigaRuntimeCases(defaultPromptEvalCases)
        let reportURL = try writeStrategicEvalReport(results, suffix: "default-prompts-vamiga-runtime")

        print("Default prompt vAmiga runtime eval report: \(reportURL.path)")
        XCTAssertTrue(results.allSatisfy(\.passed), defaultPromptFailureSummary(results))
    }

    private func routeAndMarkerResult(for evalCase: PromptEvalCase) -> PromptEvalResult {
        guard let match = AssistantPromptTemplate.match(for: evalCase.prompt) else {
            return PromptEvalResult(evalCase: evalCase, templateID: nil, failures: ["no deterministic template matched"])
        }

        var failures: [String] = []
        if match.id != evalCase.expectedTemplateID {
            failures.append("expected template \(evalCase.expectedTemplateID), got \(match.id)")
        }

        let missingMarkers = evalCase.markers.filter { !match.source.contains($0) }
        if !missingMarkers.isEmpty {
            failures.append("missing markers: \(missingMarkers.joined(separator: ", "))")
        }

        return PromptEvalResult(evalCase: evalCase, templateID: match.id, failures: failures)
    }

    private func evaluateStrategicToolchainCases(_ evalCases: [PromptEvalCase]) throws -> [PromptEvalResult] {
        let compiler = CompilerService.shared
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            throw XCTSkip("VASM compiler not found at \(compiler.vasmPath)")
        }
        guard FileManager.default.fileExists(atPath: compiler.xdftoolPath) else {
            throw XCTSkip("xdftool not found at \(compiler.xdftoolPath)")
        }

        let outputRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("strategic_eval_\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: outputRoot, withIntermediateDirectories: true)

        var compileCache: [String: (success: Bool, output: String)] = [:]
        var adfCache: [String: (success: Bool, output: String)] = [:]
        var results: [PromptEvalResult] = []

        for evalCase in evalCases {
            guard let match = AssistantPromptTemplate.match(for: evalCase.prompt) else {
                results.append(PromptEvalResult(evalCase: evalCase, templateID: nil, failures: ["no deterministic template matched"]))
                continue
            }

            var failures = routeAndMarkerResult(for: evalCase).failures
            let semantic = AssemblySemanticValidator.validate(source: match.source, prompt: evalCase.prompt)
            if !semantic.passed {
                failures.append("semantic validation failed: \(semantic.summary)")
            }

            let compileResult: (success: Bool, output: String)
            if let cached = compileCache[match.source] {
                compileResult = cached
            } else {
                compileResult = compileSource(match.source, compiler: compiler, description: "\(evalCase.name) compiles")
                compileCache[match.source] = compileResult
            }
            if !compileResult.success {
                failures.append("compile failed: \(compileResult.output)")
            }

            let adfResult: (success: Bool, output: String)
            if let cached = adfCache[match.source] {
                adfResult = cached
            } else {
                let adfURL = outputRoot.appendingPathComponent("\(match.id)-\(UUID().uuidString).adf")
                adfResult = generateADF(source: match.source, compiler: compiler, targetADF: adfURL, description: "\(evalCase.name) ADF")
                adfCache[match.source] = adfResult
            }
            if !adfResult.success {
                failures.append("ADF generation failed: \(adfResult.output)")
            }

            if evalCase.expectsVisualEvidence {
                do {
                    let visual = try PromptTemplateVisualSmokeValidator.validate(
                        match: match,
                        prompt: evalCase.prompt,
                        outputRoot: outputRoot.appendingPathComponent("expected-frames", isDirectory: true)
                    )
                    if !visual.success {
                        failures.append("expected visual evidence failed: \(visual.summary)")
                    }
                } catch {
                    failures.append("expected visual evidence threw: \(error.localizedDescription)")
                }
            }

            results.append(PromptEvalResult(evalCase: evalCase, templateID: match.id, failures: failures))
        }

        return results
    }

    private func evaluateStrategicVAmigaRuntimeCases(_ evalCases: [PromptEvalCase]) throws -> [PromptEvalResult] {
        let compiler = CompilerService.shared
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            throw XCTSkip("VASM compiler not found at \(compiler.vasmPath)")
        }
        guard FileManager.default.fileExists(atPath: compiler.xdftoolPath) else {
            throw XCTSkip("xdftool not found at \(compiler.xdftoolPath)")
        }
        guard FileManager.default.fileExists(atPath: EmulatorService.shared.defaultVAmigaPath) else {
            throw XCTSkip("vAmiga executable not found at \(EmulatorService.shared.defaultVAmigaPath)")
        }
        guard let romDirectory = runtimeSmokeValue(envKey: "AMIGA_SMOKE_ROM_DIR", fileName: "AMIGA_SMOKE_ROM_DIR") ?? strategicDefaultRomDirectory() else {
            throw XCTSkip("Set AMIGA_SMOKE_ROM_DIR or configure the app ROM directory before running strategic vAmiga runtime validation.")
        }

        let roms = EmulatorService.shared.getAvailableRoms(in: romDirectory)
        guard let smokeHardware = vAmigaSmokeHardware(from: roms) else {
            throw XCTSkip("No vAmiga-compatible A500/A500+ Kickstart ROM was found in the configured ROM directory.")
        }

        let artifactBasePath = runtimeSmokeValue(envKey: "AMIGA_SMOKE_ARTIFACT_DIR", fileName: "AMIGA_SMOKE_ARTIFACT_DIR") ?? NSTemporaryDirectory()
        let artifactRoot = URL(fileURLWithPath: artifactBasePath, isDirectory: true)
            .appendingPathComponent("AmigaPlayground/strategic-vamiga-runtime-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: artifactRoot, withIntermediateDirectories: true)

        UserDefaults.standard.set(romDirectory, forKey: "romsDirectoryPath")

        var compileCache: [String: (success: Bool, output: String)] = [:]
        var adfCache: [String: (success: Bool, output: String, adfURL: URL)] = [:]
        var runtimeCache: [String: PromptTemplateRuntimeSmokeResult] = [:]
        var results: [PromptEvalResult] = []

        for evalCase in evalCases {
            guard let match = AssistantPromptTemplate.match(for: evalCase.prompt) else {
                results.append(PromptEvalResult(evalCase: evalCase, templateID: nil, failures: ["no deterministic template matched"]))
                continue
            }

            var failures = routeAndMarkerResult(for: evalCase).failures
            let semantic = AssemblySemanticValidator.validate(source: match.source, prompt: evalCase.prompt)
            if !semantic.passed {
                failures.append("semantic validation failed: \(semantic.summary)")
            }

            let compileResult: (success: Bool, output: String)
            if let cached = compileCache[match.source] {
                compileResult = cached
            } else {
                compileResult = compileSource(match.source, compiler: compiler, description: "\(evalCase.name) vAmiga runtime compile")
                compileCache[match.source] = compileResult
            }
            if !compileResult.success {
                failures.append("compile failed: \(compileResult.output)")
            }

            let adfResult: (success: Bool, output: String, adfURL: URL)
            if let cached = adfCache[match.source] {
                adfResult = cached
            } else {
                let adfURL = artifactRoot.appendingPathComponent("\(match.id)-\(UUID().uuidString).adf")
                let generatedADF = generateADF(source: match.source, compiler: compiler, targetADF: adfURL, description: "\(evalCase.name) vAmiga runtime ADF")
                adfResult = (generatedADF.success, generatedADF.output, adfURL)
                adfCache[match.source] = adfResult
            }
            if !adfResult.success {
                failures.append("ADF generation failed: \(adfResult.output)")
            }

            if compileResult.success && adfResult.success {
                let runtimeResult: PromptTemplateRuntimeSmokeResult
                if let cached = runtimeCache[match.source] {
                    runtimeResult = cached
                } else {
                    let config = EmulatorLaunchConfig(
                        backend: .vAmiga,
                        adfPath: adfResult.adfURL.path,
                        romRelativePath: smokeHardware.rom.relativePath,
                        model: smokeHardware.model,
                        chipRamMb: smokeHardware.chipRam,
                        fastRamMb: "0 MB",
                        cpu: "68000",
                        jit: false,
                        customArgs: "",
                        vAmigaExecutablePath: EmulatorService.shared.defaultVAmigaPath,
                        vAmigaCustomArgs: ""
                    )
                    runtimeResult = try PromptTemplateRuntimeSmokeValidator.runEmulatorSmoke(
                        config: config,
                        match: match,
                        prompt: evalCase.prompt,
                        outputRoot: artifactRoot,
                        captureDelay: 6.0
                    )
                    runtimeCache[match.source] = runtimeResult
                    Thread.sleep(forTimeInterval: 0.5)
                }

                if !runtimeResult.success {
                    failures.append("vAmiga runtime smoke failed: \(runtimeResult.summary)")
                }
                if runtimeResult.nonBlackPixels <= 0 {
                    failures.append("vAmiga frame was black")
                }
                if evalCase.expectsVisualEvidence && match.id.contains("text") && runtimeResult.brightBandPixels <= 0 {
                    failures.append("vAmiga frame missing bright text-band evidence")
                }
            }

            results.append(PromptEvalResult(evalCase: evalCase, templateID: match.id, failures: failures))
        }

        return results
    }

    private func compileSource(_ source: String, compiler: CompilerService, description: String) -> (success: Bool, output: String) {
        let compileExpectation = expectation(description: description)
        var compileSucceeded = false
        var compileOutput = ""

        compiler.compile(assemblyCode: source) { success, output in
            compileSucceeded = success
            compileOutput = output
            compileExpectation.fulfill()
        }

        wait(for: [compileExpectation], timeout: 10.0)
        return (compileSucceeded, compileOutput)
    }

    private func generateADF(source: String, compiler: CompilerService, targetADF: URL, description: String) -> (success: Bool, output: String) {
        let adfExpectation = expectation(description: description)
        var adfSucceeded = false
        var adfOutput = ""

        compiler.generateBootableADF(assemblyCode: source, targetADFPath: targetADF.path) { success, output in
            adfSucceeded = success
            adfOutput = output
            adfExpectation.fulfill()
        }

        wait(for: [adfExpectation], timeout: 10.0)
        return (adfSucceeded, adfOutput)
    }

    private func assertStrategicPassRates(_ results: [PromptEvalResult], context: String) {
        for level in PromptEvalLevel.allCases {
            let levelResults = results.filter { $0.evalCase.level == level }
            guard !levelResults.isEmpty else { continue }
            let passed = levelResults.filter(\.passed).count
            let rate = Double(passed) / Double(levelResults.count)
            let failures = levelResults
                .filter { !$0.passed }
                .prefix(10)
                .map { "- \($0.evalCase.prompt): \($0.failures.joined(separator: "; "))" }
                .joined(separator: "\n")

            XCTAssertGreaterThanOrEqual(
                rate,
                level.requiredPassRate,
                "Level \(level.rawValue) \(context) pass rate \(formattedPercent(rate)) is below target \(formattedPercent(level.requiredPassRate)).\n\(failures)"
            )
        }
    }

    private func defaultPromptFailureSummary(_ results: [PromptEvalResult]) -> String {
        results
            .filter { !$0.passed }
            .map { "- \($0.evalCase.name): \($0.failures.joined(separator: "; "))" }
            .joined(separator: "\n")
    }

    private func writeStrategicEvalReport(_ results: [PromptEvalResult], suffix: String) throws -> URL {
        let reportRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("AmigaPlayground/strategic-eval", isDirectory: true)
        let reportURL = reportRoot.appendingPathComponent("strategic-eval-\(suffix)-\(UUID().uuidString).md")
        try FileManager.default.createDirectory(at: reportRoot, withIntermediateDirectories: true)

        let summary = PromptEvalLevel.allCases.map { level -> String in
            let levelResults = results.filter { $0.evalCase.level == level }
            let passed = levelResults.filter(\.passed).count
            let rate = Double(passed) / Double(levelResults.count)
            return "- Level \(level.rawValue): \(passed)/\(levelResults.count) passed (\(formattedPercent(rate))), target \(formattedPercent(level.requiredPassRate))"
        }.joined(separator: "\n")

        let rows = results.map { result in
            "| \(result.evalCase.level.rawValue) | \(markdownCell(result.evalCase.name)) | \(markdownCell(result.evalCase.prompt)) | \(markdownCell(result.templateID ?? "none")) | \(result.passed ? "pass" : "fail") | \(markdownCell(result.failures.joined(separator: "; "))) |"
        }.joined(separator: "\n")

        let markdown = """
        # Strategic Prompt Eval

        \(summary)

        | level | category | prompt | template | result | failures |
        | --- | --- | --- | --- | --- | --- |
        \(rows)
        """
        try markdown.write(to: reportURL, atomically: true, encoding: .utf8)
        return reportURL
    }

    private func formattedPercent(_ value: Double) -> String {
        String(format: "%.1f%%", value * 100)
    }

    private func markdownCell(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "|", with: "\\|")
    }

    func testPromptTemplateVisualSmokeArtifactsForGoal2BenchmarkPrompts() throws {
        let outputRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("goal2_visual_smoke_tests_\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: outputRoot) }

        for benchmark in goal2BenchmarkPrompts {
            let match = try XCTUnwrap(AssistantPromptTemplate.match(for: benchmark.prompt))
            let result = try PromptTemplateVisualSmokeValidator.validate(match: match, prompt: benchmark.prompt, outputRoot: outputRoot)

            XCTAssertTrue(result.success, "\(benchmark.name) visual smoke should pass")
            XCTAssertGreaterThan(result.nonBlackPixels, 0)
            XCTAssertTrue(FileManager.default.fileExists(atPath: result.framePath))
            XCTAssertTrue(FileManager.default.fileExists(atPath: URL(fileURLWithPath: result.artifactDirectory).appendingPathComponent("manifest.json").path))
            XCTAssertTrue(FileManager.default.fileExists(atPath: URL(fileURLWithPath: result.artifactDirectory).appendingPathComponent("summary.md").path))
        }
    }

    func testPromptTemplateBenchmarkReportWritesMarkdownTable() throws {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("goal2_benchmark_report_\(UUID().uuidString)")
            .appendingPathComponent("benchmark.md")
        defer { try? FileManager.default.removeItem(at: outputURL.deletingLastPathComponent()) }

        let rows = try goal2BenchmarkPrompts.map { benchmark -> PromptTemplateBenchmarkRow in
            let match = try XCTUnwrap(AssistantPromptTemplate.match(for: benchmark.prompt))
            let visualSmoke = try PromptTemplateVisualSmokeValidator.validate(match: match, prompt: benchmark.prompt)
            return PromptTemplateBenchmarkRow(
                prompt: benchmark.prompt,
                template: match.name,
                compile: "pass",
                semantic: "pass",
                adf: "pass",
                emulatorSmoke: visualSmoke.success ? "frame-pass" : "frame-fail",
                result: visualSmoke.success ? "pass" : "fail"
            )
        }

        try PromptTemplateBenchmarkReporter.write(rows: rows, to: outputURL)

        let markdown = try String(contentsOf: outputURL)
        XCTAssertTrue(markdown.contains("| prompt | template | compile | semantic | ADF | emulator smoke | result |"))
        XCTAssertTrue(markdown.contains("static copper bars"))
        XCTAssertTrue(markdown.contains("Starfield"))
        XCTAssertTrue(markdown.contains("Bouncing sprite"))
        XCTAssertTrue(markdown.contains("Color-cycling text"))
    }

    func testPromptTemplateRuntimeSmokeAnalyzesScreenshotPixels() throws {
        let screenshotURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("runtime_smoke_screenshot_\(UUID().uuidString).png")
        defer { try? FileManager.default.removeItem(at: screenshotURL) }

        let width = 80
        let height = 60
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )
        let black = NSColor.black
        let yellow = NSColor(calibratedRed: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        for y in 0..<height {
            for x in 0..<width {
                bitmap?.setColor(black, atX: x, y: y)
            }
        }
        for y in 24..<34 {
            for x in 25..<55 {
                bitmap?.setColor(yellow, atX: x, y: y)
            }
        }
        let pngData = try XCTUnwrap(bitmap?.representation(using: .png, properties: [:]))
        try pngData.write(to: screenshotURL)

        let analysis = try PromptTemplateRuntimeSmokeValidator.analyzeScreenshot(at: screenshotURL, expectsTextBand: true)

        XCTAssertGreaterThan(analysis.nonBlackPixels, 0)
        XCTAssertGreaterThan(analysis.brightBandPixels, 0)
    }

    func testPromptTemplateRuntimeSmokeAnalyzesVAmigaRawFramePixels() throws {
        let frameURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("runtime_smoke_vamiga_frame_\(UUID().uuidString).raw")
        defer { try? FileManager.default.removeItem(at: frameURL) }

        let width = 716
        let height = 285
        var bytes = [UInt8](repeating: 0x10, count: width * height * 3)
        for y in 105..<150 {
            for x in 240..<470 {
                let offset = (y * width + x) * 3
                bytes[offset] = 0xff
                bytes[offset + 1] = 0xff
                bytes[offset + 2] = 0xd0
            }
        }
        try Data(bytes).write(to: frameURL)

        let analysis = try PromptTemplateRuntimeSmokeValidator.analyzeScreenshot(at: frameURL, expectsTextBand: true)

        XCTAssertGreaterThan(analysis.nonBlackPixels, 0)
        XCTAssertGreaterThan(analysis.brightBandPixels, 0)
    }

    func testPromptTemplateRuntimeSmokeLaunchesFSUAEWhenEnabled() throws {
        let enableFlagPath = FileManager.default.temporaryDirectory.appendingPathComponent("AMIGA_RUN_EMULATOR_SMOKE").path
        let globalEnableFlagPath = "/private/tmp/AMIGA_RUN_EMULATOR_SMOKE"
        let isEnabled = ProcessInfo.processInfo.environment["AMIGA_RUN_EMULATOR_SMOKE"] == "1"
            || FileManager.default.fileExists(atPath: enableFlagPath)
            || FileManager.default.fileExists(atPath: globalEnableFlagPath)
        guard isEnabled else {
            throw XCTSkip("Set AMIGA_RUN_EMULATOR_SMOKE=1 or create \(enableFlagPath) to launch FS-UAE and capture runtime screenshots.")
        }

        let compiler = CompilerService.shared
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            throw XCTSkip("VASM compiler not found at \(compiler.vasmPath)")
        }
        guard FileManager.default.fileExists(atPath: compiler.xdftoolPath) else {
            throw XCTSkip("xdftool not found at \(compiler.xdftoolPath)")
        }
        guard FileManager.default.fileExists(atPath: "/Applications/FS-UAE.app") else {
            throw XCTSkip("FS-UAE app not found at /Applications/FS-UAE.app")
        }

        guard let romDirectory = runtimeSmokeValue(envKey: "AMIGA_SMOKE_ROM_DIR", fileName: "AMIGA_SMOKE_ROM_DIR") else {
            throw XCTSkip("Set AMIGA_SMOKE_ROM_DIR or write /private/tmp/AMIGA_SMOKE_ROM_DIR before launching the emulator smoke test.")
        }
        guard let romFilename = runtimeSmokeValue(envKey: "AMIGA_SMOKE_ROM", fileName: "AMIGA_SMOKE_ROM") else {
            throw XCTSkip("Set AMIGA_SMOKE_ROM or write /private/tmp/AMIGA_SMOKE_ROM before launching the emulator smoke test.")
        }
        let artifactBasePath = runtimeSmokeValue(envKey: "AMIGA_SMOKE_ARTIFACT_DIR", fileName: "AMIGA_SMOKE_ARTIFACT_DIR") ?? NSTemporaryDirectory()
        let artifactRoot = URL(fileURLWithPath: artifactBasePath, isDirectory: true)
            .appendingPathComponent("AmigaPlayground/runtime-smoke-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: artifactRoot, withIntermediateDirectories: true)

        UserDefaults.standard.set(romDirectory, forKey: "romsDirectoryPath")

        var rows: [PromptTemplateBenchmarkRow] = []
        for benchmark in goal2BenchmarkPrompts {
            let match = try XCTUnwrap(AssistantPromptTemplate.match(for: benchmark.prompt))
            let source = match.source
            let semantic = AssemblySemanticValidator.validate(source: source, prompt: benchmark.prompt)
            XCTAssertTrue(semantic.passed, "\(benchmark.name) should pass semantic gate before emulator launch: \(semantic.summary)")

            let adfURL = artifactRoot.appendingPathComponent("\(match.id).adf")
            let adfExpectation = expectation(description: "\(benchmark.name) ADF")
            var adfSucceeded = false
            var adfMessage = ""
            compiler.generateBootableADF(assemblyCode: source, targetADFPath: adfURL.path) { success, output in
                adfSucceeded = success
                adfMessage = output
                adfExpectation.fulfill()
            }
            wait(for: [adfExpectation], timeout: 10.0)
            XCTAssertTrue(adfSucceeded, "\(benchmark.name) ADF generation failed:\n\(adfMessage)")

            let config = EmulatorLaunchConfig(
                backend: .fsUAE,
                adfPath: adfURL.path,
                romRelativePath: romFilename,
                model: "A1200",
                chipRamMb: "2 MB",
                fastRamMb: "0 MB",
                cpu: "68020",
                jit: false,
                customArgs: "--fullscreen=0 --window_width=724 --window_height=566 --audio_output=none",
                vAmigaExecutablePath: EmulatorService.shared.defaultVAmigaPath,
                vAmigaCustomArgs: ""
            )
            let runtimeResult = try PromptTemplateRuntimeSmokeValidator.runEmulatorSmoke(
                config: config,
                match: match,
                prompt: benchmark.prompt,
                outputRoot: artifactRoot,
                captureDelay: 5.0
            )

            XCTAssertTrue(runtimeResult.success, "\(benchmark.name) runtime smoke failed:\n\(runtimeResult.summary)\n\(runtimeResult.launchSummary)\nArtifacts: \(runtimeResult.artifactDirectory)")
            rows.append(PromptTemplateBenchmarkRow(
                prompt: benchmark.prompt,
                template: match.name,
                compile: "pass",
                semantic: semantic.passed ? "pass" : "fail",
                adf: adfSucceeded ? "pass" : "fail",
                emulatorSmoke: runtimeResult.success ? "pass" : "fail",
                result: runtimeResult.success ? "pass" : "fail"
            ))
        }

        let reportURL = artifactRoot.appendingPathComponent("benchmark.md")
        try PromptTemplateBenchmarkReporter.write(rows: rows, to: reportURL)
        print("Runtime smoke artifacts: \(artifactRoot.path)")
        XCTAssertTrue(FileManager.default.fileExists(atPath: reportURL.path))
    }

    func testPromptTemplateRuntimeSmokeLaunchesVAmigaWhenEnabled() throws {
        let enableFlagPath = FileManager.default.temporaryDirectory.appendingPathComponent("AMIGA_RUN_VAMIGA_SMOKE").path
        let globalEnableFlagPath = "/private/tmp/AMIGA_RUN_VAMIGA_SMOKE"
        let isEnabled = ProcessInfo.processInfo.environment["AMIGA_RUN_VAMIGA_SMOKE"] == "1"
            || FileManager.default.fileExists(atPath: enableFlagPath)
            || FileManager.default.fileExists(atPath: globalEnableFlagPath)
        guard isEnabled else {
            throw XCTSkip("Set AMIGA_RUN_VAMIGA_SMOKE=1 or create \(enableFlagPath) to launch vAmiga and capture runtime raw frames.")
        }

        let compiler = CompilerService.shared
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            throw XCTSkip("VASM compiler not found at \(compiler.vasmPath)")
        }
        guard FileManager.default.fileExists(atPath: compiler.xdftoolPath) else {
            throw XCTSkip("xdftool not found at \(compiler.xdftoolPath)")
        }
        guard FileManager.default.fileExists(atPath: EmulatorService.shared.defaultVAmigaPath) else {
            throw XCTSkip("vAmiga executable not found at \(EmulatorService.shared.defaultVAmigaPath)")
        }

        guard let romDirectory = runtimeSmokeValue(envKey: "AMIGA_SMOKE_ROM_DIR", fileName: "AMIGA_SMOKE_ROM_DIR") else {
            throw XCTSkip("Set AMIGA_SMOKE_ROM_DIR or write /private/tmp/AMIGA_SMOKE_ROM_DIR before launching the vAmiga smoke test.")
        }
        let roms = EmulatorService.shared.getAvailableRoms(in: romDirectory)
        guard let smokeHardware = vAmigaSmokeHardware(from: roms) else {
            throw XCTSkip("No vAmiga-compatible A500/A500+ Kickstart ROM was found in \(romDirectory).")
        }
        let artifactBasePath = runtimeSmokeValue(envKey: "AMIGA_SMOKE_ARTIFACT_DIR", fileName: "AMIGA_SMOKE_ARTIFACT_DIR") ?? NSTemporaryDirectory()
        let artifactRoot = URL(fileURLWithPath: artifactBasePath, isDirectory: true)
            .appendingPathComponent("AmigaPlayground/vamiga-runtime-smoke-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: artifactRoot, withIntermediateDirectories: true)

        UserDefaults.standard.set(romDirectory, forKey: "romsDirectoryPath")

        var rows: [PromptTemplateBenchmarkRow] = []
        for benchmark in goal2BenchmarkPrompts {
            let match = try XCTUnwrap(AssistantPromptTemplate.match(for: benchmark.prompt))
            let source = match.source
            let semantic = AssemblySemanticValidator.validate(source: source, prompt: benchmark.prompt)
            XCTAssertTrue(semantic.passed, "\(benchmark.name) should pass semantic gate before vAmiga launch: \(semantic.summary)")

            let adfURL = artifactRoot.appendingPathComponent("\(match.id).adf")
            let adfExpectation = expectation(description: "\(benchmark.name) vAmiga ADF")
            var adfSucceeded = false
            var adfMessage = ""
            compiler.generateBootableADF(assemblyCode: source, targetADFPath: adfURL.path) { success, output in
                adfSucceeded = success
                adfMessage = output
                adfExpectation.fulfill()
            }
            wait(for: [adfExpectation], timeout: 10.0)
            XCTAssertTrue(adfSucceeded, "\(benchmark.name) ADF generation failed:\n\(adfMessage)")

            let config = EmulatorLaunchConfig(
                backend: .vAmiga,
                adfPath: adfURL.path,
                romRelativePath: smokeHardware.rom.relativePath,
                model: smokeHardware.model,
                chipRamMb: smokeHardware.chipRam,
                fastRamMb: "0 MB",
                cpu: "68000",
                jit: false,
                customArgs: "",
                vAmigaExecutablePath: EmulatorService.shared.defaultVAmigaPath,
                vAmigaCustomArgs: ""
            )
            let runtimeResult = try PromptTemplateRuntimeSmokeValidator.runEmulatorSmoke(
                config: config,
                match: match,
                prompt: benchmark.prompt,
                outputRoot: artifactRoot,
                captureDelay: 6.0
            )

            XCTAssertTrue(runtimeResult.success, "\(benchmark.name) vAmiga runtime smoke failed:\n\(runtimeResult.summary)\n\(runtimeResult.launchSummary)\nArtifacts: \(runtimeResult.artifactDirectory)")
            rows.append(PromptTemplateBenchmarkRow(
                prompt: benchmark.prompt,
                template: match.name,
                compile: "pass",
                semantic: semantic.passed ? "pass" : "fail",
                adf: adfSucceeded ? "pass" : "fail",
                emulatorSmoke: runtimeResult.success ? "pass" : "fail",
                result: runtimeResult.success ? "pass" : "fail"
            ))
            Thread.sleep(forTimeInterval: 1.0)
        }

        let reportURL = artifactRoot.appendingPathComponent("benchmark-vamiga.md")
        try PromptTemplateBenchmarkReporter.write(rows: rows, to: reportURL)
        print("vAmiga runtime smoke artifacts: \(artifactRoot.path)")
        XCTAssertTrue(FileManager.default.fileExists(atPath: reportURL.path))
    }

    private func runtimeSmokeValue(envKey: String, fileName: String) -> String? {
        if let value = ProcessInfo.processInfo.environment[envKey]?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty {
            return value
        }

        let configURL = URL(fileURLWithPath: "/private/tmp", isDirectory: true).appendingPathComponent(fileName)
        guard let fileValue = try? String(contentsOf: configURL).trimmingCharacters(in: .whitespacesAndNewlines),
              !fileValue.isEmpty else {
            return nil
        }
        return fileValue
    }

    private func strategicDefaultRomDirectory() -> String? {
        let configuredPath = UserDefaults.standard.string(forKey: "romsDirectoryPath")?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let configuredPath, !configuredPath.isEmpty, FileManager.default.fileExists(atPath: configuredPath) {
            return configuredPath
        }

        let defaultPath = EmulatorService.defaultRomsDirectory
        guard FileManager.default.fileExists(atPath: defaultPath) else {
            return nil
        }
        return defaultPath
    }

    private func vAmigaSmokeHardware(from roms: [RomEntry]) -> (rom: RomEntry, model: String, chipRam: String)? {
        let sortedCandidates = roms.compactMap { rom -> (rom: RomEntry, score: Int, model: String, chipRam: String)? in
            let name = rom.displayName.lowercased()
            if ["bootstrap", "cdtv", "cd32", "extended", "a3000", "beta", "proto", "[h]", "[o]"].contains(where: name.contains) {
                return nil
            }

            let attributes = try? FileManager.default.attributesOfItem(atPath: rom.absolutePath)
            let fileSize = (attributes?[.size] as? NSNumber)?.intValue ?? 0
            var score = 0
            var model = "A500"
            var chipRam = "1 MB"

            if name.contains("a500+") || name.contains("a500 plus") || name.contains("390979") || name.contains("2.04") || name.contains("37.175") {
                score += 30
                model = "A500+"
            }
            if name.contains("kick13") || name.contains("1.3") || name.contains("34.5") || name.contains("34.005") || name.contains("315093-02") {
                score += 60
                model = "A500"
            }
            if name.contains("a500") || name.contains("a2000") {
                score += 20
            }
            if fileSize == 262_144 {
                score += model == "A500" ? 20 : 0
            }
            if fileSize == 524_288 {
                score += model == "A500+" ? 15 : 0
            }
            if name.contains("[!]") {
                score += 10
            }
            if score < 50 {
                return nil
            }

            if model == "A500+" {
                chipRam = "1 MB"
            }
            return (rom, score, model, chipRam)
        }

        return sortedCandidates.max { lhs, rhs in
            lhs.score < rhs.score
        }.map { ($0.rom, $0.model, $0.chipRam) }
    }

    func testAssemblySourceFormatterRepairsCommonModelSyntaxDrift() {
        let source = """
        SECTION Code,CODE
        CONST EQU $1234
        _Start:
        moveq.l #0,d0
        MOVE #0x00F,d1
        rts
        """

        let formatted = AssemblySourceFormatter.vasmReadySource(from: source)

        XCTAssertTrue(formatted.contains("            SECTION Code,CODE"))
        XCTAssertTrue(formatted.contains("CONST       EQU $1234"))
        XCTAssertTrue(formatted.contains("            moveq.l #0,d0"))
        XCTAssertTrue(formatted.contains("            MOVE #$00F,d1"))
        XCTAssertTrue(formatted.contains("            rts"))
    }

    func testAssemblySemanticValidatorRejectsKnownModelFailurePatterns() {
        let source = """
                    SECTION Code,CODE
                    XDEF _Start
        _Start:
                    move.w #0x00f,d8
                    move.w #BLUE,DFF180
                    dc.w #$fffe,$0180
                    dec.l d0
                    rts
        """

        let result = AssemblySemanticValidator.validate(source: source, prompt: "set background color")

        XCTAssertFalse(result.passed)
        XCTAssertTrue(result.summary.contains("invalid register d8"))
        XCTAssertTrue(result.summary.contains("C-style hex literal 0x00f"))
        XCTAssertTrue(result.summary.contains("bare custom-chip register DFF180"))
        XCTAssertTrue(result.summary.contains("undefined symbolic color BLUE"))
        XCTAssertTrue(result.summary.contains("immediate marker # is invalid in dc data directives"))
        XCTAssertTrue(result.summary.contains("invalid pseudo instruction dec.l"))
    }

    func testAssemblySemanticValidatorRequiresCompleteExecutableStructure() {
        let source = """
        SECTION CODE
        exit:
            rts
            bra exit
        """

        let result = AssemblySemanticValidator.validate(source: source, prompt: "Generate a minimal Amiga 68000 assembly program that exits cleanly.")

        XCTAssertFalse(result.passed)
        XCTAssertTrue(result.summary.contains("missing SECTION Code,CODE"))
        XCTAssertTrue(result.summary.contains("missing XDEF _Start"))
        XCTAssertTrue(result.summary.contains("missing _Start label"))
    }

    func testAssemblySemanticValidatorRequiresCopperBehaviorForBouncingPrompt() {
        let source = """
                    SECTION Code,CODE,CHIP
                    XDEF _Start
        _Start:
                    lea $dff000,a6
                    lea CopperList(pc),a0
                    move.l a0,$80(a6)
                    move.w #$0000,$88(a6)
                    move.w #$8280,$96(a6)
                    rts
        CopperList:
                    dc.w $0180,$0f00
                    dc.w $ffff,$fffe
        """

        let result = AssemblySemanticValidator.validate(source: source, prompt: "generate a bouncing multi color copper list")

        XCTAssertFalse(result.passed)
        XCTAssertTrue(result.summary.contains("vertical blank wait"))
        XCTAssertTrue(result.summary.contains("left mouse exit"))
        XCTAssertTrue(result.summary.contains("animated copper wait words"))
    }

    func testAssemblySemanticValidatorAcceptsBouncingCopperTemplate() throws {
        let source = try XCTUnwrap(AssistantPromptTemplate.source(for: "generate a bouncing multi color copper list"))

        let result = AssemblySemanticValidator.validate(source: source, prompt: "generate a bouncing multi color copper list")

        XCTAssertTrue(result.passed, result.summary)
    }

    func testAssemblySemanticValidatorRejectsWaitOnlyBlitter() {
        let source = """
                    SECTION Code,CODE,CHIP
                    XDEF _Start
        _Start:
                    lea $dff000,a6
        .wait:
                    btst #6,$02(a6)
                    bne.s .wait
                    rts
        """

        let result = AssemblySemanticValidator.validate(source: source, prompt: "Generate a blitter clear routine")

        XCTAssertFalse(result.passed)
        XCTAssertTrue(result.summary.contains("missing blitter wait after BLTSIZE"))
        XCTAssertTrue(result.summary.contains("missing BLTCON0 $40(a6) setup"))
        XCTAssertTrue(result.summary.contains("missing BLTSIZE $58(a6) start"))
    }

    func testAssemblySemanticValidatorPrefersCanonicalBlitterWait() {
        let source = """
                    SECTION Code,CODE,CHIP
                    XDEF _Start
        _Start:
                    lea $dff000,a6
        .waitBefore:
                    btst #14,$02(a6)
                    bne.s .waitBefore
                    move.w #$0100,$40(a6)
                    move.l a0,$54(a6)
                    move.w #$0000,$66(a6)
                    move.w #$0401,$58(a6)
        .waitAfter:
                    btst #14,$02(a6)
                    bne.s .waitAfter
                    rts
        """

        let result = AssemblySemanticValidator.validate(source: source, prompt: "Generate a blitter clear routine")

        XCTAssertFalse(result.passed)
        XCTAssertTrue(result.summary.contains("non-canonical blitter wait"))
    }

    func testAssemblySemanticValidatorChecksAudioDMA() {
        let source = """
                    SECTION Code,CODE,CHIP
                    XDEF _Start
        _Start:
                    lea $dff000,a6
                    move.w #$0001,$a4(a6)
                    move.w #$00c0,$a6(a6)
                    move.w #$0040,$a8(a6)
                    move.w #$8201,$96(a6)
                    rts
        """

        let result = AssemblySemanticValidator.validate(source: source, prompt: "Generate an audio DMA routine")

        XCTAssertFalse(result.passed)
        XCTAssertTrue(result.summary.contains("missing AUD0LCH setup"))
    }

    func testAssemblySemanticValidatorChecksSpriteSetup() {
        let source = """
                    SECTION Code,CODE,CHIP
                    XDEF _Start
        _Start:
                    lea $dff000,a6
                    rts
        """

        let result = AssemblySemanticValidator.validate(source: source, prompt: "Generate a sprite routine")

        XCTAssertFalse(result.passed)
        XCTAssertTrue(result.summary.contains("missing sprite 0 pointer/setup"))
        XCTAssertTrue(result.summary.contains("missing sprite data terminator"))
    }

    func testAssemblySemanticValidatorChecksInputRead() {
        let source = """
                    SECTION Code,CODE
                    XDEF _Start
        _Start:
                    moveq #0,d0
                    rts
        """

        let result = AssemblySemanticValidator.validate(source: source, prompt: "Generate a joystick input routine")

        XCTAssertFalse(result.passed)
        XCTAssertTrue(result.summary.contains("missing CIA/joystick/mouse hardware read"))
    }

    func testAssemblyRepairPromptIncludesSemanticFailuresAndSource() {
        let prompt = AssemblyRepairPromptBuilder.prompt(
            originalRequest: "Generate a blitter clear routine",
            source: "move.w #0x00f,d8",
            compilerOutput: "unknown mnemonic",
            semanticFailures: ["invalid register d8", "C-style hex literal 0x00f"],
            attempt: 2
        )

        XCTAssertTrue(prompt.contains("Attempt 2"))
        XCTAssertTrue(prompt.contains("unknown mnemonic"))
        XCTAssertTrue(prompt.contains("invalid register d8"))
        XCTAssertTrue(prompt.contains("C-style hex literal 0x00f"))
        XCTAssertTrue(prompt.contains("move.w #0x00f,d8"))
        XCTAssertTrue(prompt.contains("Generate a blitter clear routine"))
        XCTAssertTrue(prompt.contains("btst #6,$02(a6)"))
        XCTAssertTrue(prompt.contains("Return ONLY the entire corrected code block"))
    }

    func testGenerationContractNamesObservedInvalidModelPatterns() {
        let prompt = OllamaService.generationContractPrompt

        XCTAssertTrue(prompt.contains("Do not split SECTION Code,CODE"))
        XCTAssertTrue(prompt.contains("Use $dff000,a6 plus register offsets"))
        XCTAssertTrue(prompt.contains("Do not emit dec.l"))
        XCTAssertTrue(prompt.contains("Use $00ff style hexadecimal constants"))
        XCTAssertTrue(prompt.contains("Do not invent symbols such as BLUE"))
        XCTAssertTrue(prompt.contains("Never append size specifiers as a third operand"))
        XCTAssertTrue(prompt.contains("Do not emit a write pseudo-instruction"))
        XCTAssertTrue(prompt.contains("Never make PC-relative writes"))
        XCTAssertTrue(prompt.contains("Copper lists must live in Chip RAM"))
    }

    func testAssistantChatSessionDoesNotInjectConnectionErrorContainingAmigaTokens() {
        let session = AssistantChatSession()
        _ = session.submit("write a custom animated copper list")

        let response = """
        +------------------------------------------------------------(0)
        .ankey
        +------------------------------------------------------------(0)
        .copper
        * Connection Error: model 'antigravity-amiga-68k' not found
        * Ensure your LLM server (Ollama/LM Studio) is running on the specified port.
        """

        let result = session.complete(fullResponse: response, streamedResponse: "")

        XCTAssertNil(result.injectedCode)
        XCTAssertNil(result.consoleMessage)
        XCTAssertFalse(session.isLikelyInjectableCode(response))
    }

    func testAssistantChatSessionAppendsConnectionErrorAndStopsGenerating() {
        let session = AssistantChatSession()
        _ = session.submit("build an animated copper list")

        session.fail(NSError(domain: "TestLLM", code: 404, userInfo: [NSLocalizedDescriptionKey: "Repository Not Found"]))

        XCTAssertFalse(session.isGenerating)
        XCTAssertTrue(session.currentGeneration.isEmpty)
        XCTAssertEqual(session.messages.map(\.role), ["user", "assistant"])
        XCTAssertTrue(session.messages[1].content.contains("Connection Error: Repository Not Found"))
    }

    func testAssistantChatSessionCancelStopsGenerationAndKeepsPartialResponse() {
        let session = AssistantChatSession()
        _ = session.submit("build an animated copper list")
        session.appendChunk("SECTION Code,CODE,CHIP\n")
        session.appendChunk("CopperList:")

        session.cancel()

        XCTAssertFalse(session.isGenerating)
        XCTAssertTrue(session.currentGeneration.isEmpty)
        XCTAssertEqual(session.messages.map(\.role), ["user", "assistant"])
        XCTAssertEqual(session.messages[1].content, "SECTION Code,CODE,CHIP\nCopperList:\n\n[Stopped]")
    }

    func testAssistantChatSessionCancelWithoutPartialResponseAddsStoppedMessage() {
        let session = AssistantChatSession()
        _ = session.submit("build an animated copper list")

        session.cancel()

        XCTAssertFalse(session.isGenerating)
        XCTAssertTrue(session.currentGeneration.isEmpty)
        XCTAssertEqual(session.messages.map(\.role), ["user", "assistant"])
        XCTAssertEqual(session.messages[1].content, "Generation stopped.")
    }

    func testAssistantChatSessionReturnsOnlyUserPromptForReuse() {
        let session = AssistantChatSession()
        _ = session.submit("  write a custom animated copper list  ")
        let userMessage = session.messages[0]

        session.fail(NSError(domain: "TestLLM", code: 404, userInfo: [NSLocalizedDescriptionKey: "Repository Not Found"]))
        let assistantMessage = session.messages[1]

        XCTAssertEqual(session.reusablePrompt(from: userMessage), "write a custom animated copper list")
        XCTAssertNil(session.reusablePrompt(from: assistantMessage))
    }

    // MARK: - Emulator Service Tests

    func testMapRamToKb() {
        let service = EmulatorService.shared

        // Test standard KB Chip RAM
        XCTAssertEqual(service.mapRamToKb(ramStr: "512 KB", isChip: true), 512)

        // Test standard MB Chip RAM
        XCTAssertEqual(service.mapRamToKb(ramStr: "1 MB", isChip: true), 1024)
        XCTAssertEqual(service.mapRamToKb(ramStr: "2 MB", isChip: true), 2048)
        XCTAssertEqual(service.mapRamToKb(ramStr: "8 MB", isChip: true), 8192)

        // Test Fast RAM
        XCTAssertEqual(service.mapRamToKb(ramStr: "0 MB", isChip: false), 0)
        XCTAssertEqual(service.mapRamToKb(ramStr: "16 MB", isChip: false), 16384)
        XCTAssertEqual(service.mapRamToKb(ramStr: "64 MB", isChip: false), 65536)

        // Test invalid default values
        XCTAssertEqual(service.mapRamToKb(ramStr: "Invalid RAM", isChip: true), 512)
        XCTAssertEqual(service.mapRamToKb(ramStr: "Invalid RAM", isChip: false), 0)
    }

    func testEmulatorGetAvailableRoms() {
        let service = EmulatorService.shared
        let roms = service.getAvailableRoms()

        // If the directory actually exists, verify filtering
        if FileManager.default.fileExists(atPath: service.romsDirectory) {
            for rom in roms {
                let lower = rom.relativePath.lowercased()
                XCTAssertTrue(lower.hasSuffix(".rom"), "ROM filename \(rom.relativePath) does not have expected extension")
                XCTAssertFalse(rom.relativePath.split(separator: "/").contains { $0.hasPrefix(".") }, "ROM path \(rom.relativePath) should not contain hidden path components")
            }
        } else {
            XCTAssertTrue(roms.isEmpty, "ROM list should be empty if romsDirectory does not exist")
        }
    }

    func testRecursiveRomDiscoveryReturnsStructuredEntries() throws {
        let service = EmulatorService.shared
        let tempRoot = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let nested = tempRoot.appendingPathComponent("kickstart/v1-3-r34-005", isDirectory: true)
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)
        try Data([0, 1, 2, 3]).write(to: nested.appendingPathComponent("kickstart-v1-3-r34-005.rom"))
        try Data([0, 1, 2, 3]).write(to: nested.appendingPathComponent("ignore.zip"))
        try Data([0, 1, 2, 3]).write(to: tempRoot.appendingPathComponent(".hidden.rom"))
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let roms = service.getAvailableRoms(in: tempRoot.path)

        XCTAssertEqual(roms.count, 1)
        XCTAssertEqual(roms[0].relativePath, "kickstart/v1-3-r34-005/kickstart-v1-3-r34-005.rom")
        XCTAssertEqual(roms[0].inferredMetadata, "v1-3-r34-005")
        XCTAssertTrue(roms[0].displayName.contains("v1-3-r34-005"))
    }

    func testCustomRomsDirectory() {
        let service = EmulatorService.shared
        let originalPath = UserDefaults.standard.string(forKey: "romsDirectoryPath")

        let tempTestPath = "/tmp/test-roms-directory-non-existent"
        UserDefaults.standard.set(tempTestPath, forKey: "romsDirectoryPath")
        XCTAssertEqual(service.romsDirectory, tempTestPath)
        XCTAssertTrue(service.getAvailableRoms().isEmpty)

        // Restore original configuration
        if let original = originalPath {
            UserDefaults.standard.set(original, forKey: "romsDirectoryPath")
        } else {
            UserDefaults.standard.removeObject(forKey: "romsDirectoryPath")
        }
    }

    func testBuildFSUAEArgumentsPreservesExistingFlags() {
        let service = EmulatorService.shared
        let config = EmulatorLaunchConfig(
            backend: .fsUAE,
            adfPath: "/tmp/test.adf",
            romRelativePath: "",
            model: "A500",
            chipRamMb: "1 MB",
            fastRamMb: "8 MB",
            cpu: "68000",
            jit: false,
            customArgs: "--fullscreen --joystick_port_0=keyboard",
            vAmigaExecutablePath: service.defaultVAmigaPath,
            vAmigaCustomArgs: ""
        )

        XCTAssertEqual(service.buildFSUAEArguments(config: config), [
            "--floppy_drive_0=/tmp/test.adf",
            "--amiga_model=A500",
            "--chip_memory=1024",
            "--fast_memory=8192",
            "--cpu=68000",
            "--jit=0",
            "--fullscreen",
            "--joystick_port_0=keyboard"
        ])
    }

    func testBuildFSUAEArgumentsUsesA1200MinimumChipRam() {
        let service = EmulatorService.shared
        let config = EmulatorLaunchConfig(
            backend: .fsUAE,
            adfPath: "/tmp/test.adf",
            romRelativePath: "",
            model: "A1200",
            chipRamMb: "512 KB",
            fastRamMb: "0 MB",
            cpu: "68020",
            jit: false,
            customArgs: "",
            vAmigaExecutablePath: service.defaultVAmigaPath,
            vAmigaCustomArgs: ""
        )

        XCTAssertTrue(service.buildFSUAEArguments(config: config).contains("--chip_memory=2048"))
    }

    func testBuildFSUAEArgumentsFallsBackToFullA1200Rom() throws {
        let service = EmulatorService.shared
        let originalPath = UserDefaults.standard.string(forKey: "romsDirectoryPath")
        let tempRoot = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("AmigaPlaygroundRomFallback-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempRoot, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: tempRoot)
            if let originalPath {
                UserDefaults.standard.set(originalPath, forKey: "romsDirectoryPath")
            } else {
                UserDefaults.standard.removeObject(forKey: "romsDirectoryPath")
            }
        }

        let splitRom = tempRoot.appendingPathComponent("Kickstart - 391774-01 (USA, Europe) (v3.1 Rev 40.068) (A1200).rom")
        let fullRom = tempRoot.appendingPathComponent("Kickstart v3.1 rev 40.68 (1993)(Commodore)(A1200).rom")
        try Data(repeating: 0, count: 262_144).write(to: splitRom)
        try Data(repeating: 0, count: 524_288).write(to: fullRom)
        UserDefaults.standard.set(tempRoot.path, forKey: "romsDirectoryPath")

        let config = EmulatorLaunchConfig(
            backend: .fsUAE,
            adfPath: "/tmp/test.adf",
            romRelativePath: splitRom.lastPathComponent,
            model: "A1200",
            chipRamMb: "2 MB",
            fastRamMb: "0 MB",
            cpu: "68020",
            jit: false,
            customArgs: "",
            vAmigaExecutablePath: service.defaultVAmigaPath,
            vAmigaCustomArgs: ""
        )

        let arguments = service.buildFSUAEArguments(config: config)
        XCTAssertTrue(arguments.contains { $0.hasPrefix("--kickstart_file=") && $0.contains(fullRom.lastPathComponent) })
        XCTAssertFalse(arguments.contains { $0.hasPrefix("--kickstart_file=") && $0.contains(splitRom.lastPathComponent) })
    }

    func testBuildVAmigaArgumentsPrioritizesRetroShellValidationScript() {
        let service = EmulatorService.shared
        let config = EmulatorLaunchConfig(
            backend: .vAmiga,
            adfPath: "/tmp/test.adf",
            romRelativePath: "",
            model: "A500",
            chipRamMb: "512 KB",
            fastRamMb: "0 MB",
            cpu: "68000",
            jit: false,
            customArgs: "",
            vAmigaExecutablePath: service.defaultVAmigaPath,
            vAmigaCustomArgs: "-\"help\" --debug"
        )

        XCTAssertEqual(service.buildVAmigaArguments(config: config, scriptPath: "/tmp/session.retrosh"), [
            "-source \"/tmp/session.retrosh\"",
            "-help",
            "--debug"
        ])
    }

    func testBuildVAmigaInvocationUsesApplicationBundleDocumentLaunch() {
        let service = EmulatorService.shared
        let config = EmulatorLaunchConfig(
            backend: .vAmiga,
            adfPath: "/tmp/test.adf",
            romRelativePath: "",
            model: "A500",
            chipRamMb: "512 KB",
            fastRamMb: "0 MB",
            cpu: "68000",
            jit: false,
            customArgs: "",
            vAmigaExecutablePath: service.defaultVAmigaPath,
            vAmigaCustomArgs: "--debug"
        )

        let invocation = service.buildVAmigaInvocation(
            executablePath: "/Applications/vAmiga.app/Contents/MacOS/vAmiga",
            config: config,
            scriptPath: "/tmp/session.retrosh"
        )

        XCTAssertEqual(invocation.executablePath, "/usr/bin/open")
        XCTAssertEqual(invocation.arguments, [
            "-n",
            "-a",
            "/Applications/vAmiga.app",
            "/tmp/session.retrosh"
        ])
    }

    func testCreateVAmigaRetroShellScriptDocumentsDefaultRomPath() throws {
        let service = EmulatorService.shared
        let config = EmulatorLaunchConfig(
            backend: .vAmiga,
            adfPath: "/tmp/test.adf",
            romRelativePath: "",
            model: "A500",
            chipRamMb: "512 KB",
            fastRamMb: "0 MB",
            cpu: "68000",
            jit: false,
            customArgs: "",
            vAmigaExecutablePath: service.defaultVAmigaPath,
            vAmigaCustomArgs: ""
        )

        let scriptPath = try service.createVAmigaRetroShellScript(config: config, tracePath: "/tmp/trace.jsonl")
        defer { try? FileManager.default.removeItem(atPath: scriptPath) }
        let script = try String(contentsOfFile: scriptPath, encoding: .utf8)

        XCTAssertTrue(script.contains("AmigaPlayground vAmiga CPU trace bootstrap"))
        XCTAssertTrue(script.contains("No explicit ROM selected"))
        XCTAssertTrue(script.contains("try amiga init A500_OCS_1MB"))
        XCTAssertTrue(script.contains("try df0 insert \"/tmp/test.adf\""))
        XCTAssertTrue(script.contains("try amiga power on"))
        XCTAssertTrue(script.contains("try amiga reset"))
        XCTAssertFalse(script.contains("try df0 connect"))
        XCTAssertFalse(script.contains("try amiga run"))
        XCTAssertFalse(script.contains("try run"))
        XCTAssertTrue(script.contains("regs"))
        XCTAssertTrue(script.contains("disassemble"))
    }

    func testCreateVAmigaRetroShellScriptCanCaptureRawFrame() throws {
        let service = EmulatorService.shared
        let config = EmulatorLaunchConfig(
            backend: .vAmiga,
            adfPath: "/tmp/test.adf",
            romRelativePath: "",
            model: "A500",
            chipRamMb: "512 KB",
            fastRamMb: "0 MB",
            cpu: "68000",
            jit: false,
            customArgs: "",
            vAmigaExecutablePath: service.defaultVAmigaPath,
            vAmigaCustomArgs: "",
            vAmigaScriptScreenshotBasePath: "/tmp/amiga-smoke-frame",
            vAmigaScriptWaitSeconds: 5
        )

        let scriptPath = try service.createVAmigaRetroShellScript(config: config, tracePath: "/tmp/trace.jsonl")
        defer { try? FileManager.default.removeItem(atPath: scriptPath) }
        let script = try String(contentsOfFile: scriptPath, encoding: .utf8)

        XCTAssertTrue(script.contains("try amiga init A500_OCS_1MB"))
        XCTAssertTrue(script.contains("try df0 insert \"/tmp/test.adf\""))
        XCTAssertTrue(script.contains("Runtime smoke capture is requested later"))
        XCTAssertFalse(script.contains("wait 5"))
        XCTAssertFalse(script.contains("screenshot save \"/tmp/amiga-smoke-frame\""))
        XCTAssertFalse(script.contains("disassemble"))
        XCTAssertFalse(script.contains("break"))
    }

    func testCpuTraceParserExtractsDebuggerFields() {
        let service = EmulatorService.shared
        let records = service.parseCpuTrace("""
        PC:00F80000 SR:2700 D0:00000001 A0:00C00000
        $00F80002: MOVE.W #$4000,$DFF09A
        Breakpoint reached at $00F80010
        Watchpoint write $00DFF180
        """)

        XCTAssertEqual(records.count, 4)
        XCTAssertEqual(records[0].event, "cpu")
        XCTAssertEqual(records[0].pc, "00F80000")
        XCTAssertEqual(records[0].sr, "2700")
        XCTAssertEqual(records[0].registers["D0"], "00000001")
        XCTAssertEqual(records[1].instruction, "MOVE.W #$4000,$DFF09A")
        XCTAssertEqual(records[2].event, "breakpoint")
        XCTAssertEqual(records[3].event, "watchpoint")
    }

    func testVAmigaServerConfigPatcherPreservesExistingSettingsAndCreatesBackup() throws {
        let tempRoot = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempRoot, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let iniURL = tempRoot.appendingPathComponent("vAmiga.ini")
        try """
        [MEM]
        CHIP_RAM=512

        [SRV]
        AUTORUN0=0
        PORT0=9000
        VERBOSE0=1

        [VID]
        WHITE_NOISE=1
        """.write(to: iniURL, atomically: true, encoding: .utf8)

        let config = VAmigaServerConfig(configPath: iniURL.path)
        let patched = try VAmigaServerConfigPatcher().apply(config: config)
        let text = try String(contentsOf: iniURL, encoding: .utf8)

        XCTAssertTrue(FileManager.default.fileExists(atPath: patched.backupPath ?? ""))
        XCTAssertTrue(text.contains("[MEM]\nCHIP_RAM=512"))
        XCTAssertTrue(text.contains("[VID]\nWHITE_NOISE=1"))
        XCTAssertTrue(text.contains("[SRV]"))
        XCTAssertTrue(text.contains("ENABLE0=1"))
        XCTAssertTrue(text.contains("ENABLE1=1"))
        XCTAssertTrue(text.contains("ENABLE3=1"))
        XCTAssertTrue(text.contains("ENABLE4=1"))
        XCTAssertTrue(text.contains("AUTORUN1=1"))
        XCTAssertTrue(text.contains("AUTORUN2=1"))
        XCTAssertTrue(text.contains("PORT0=8080"))
        XCTAssertTrue(text.contains("PORT1=8081"))
        XCTAssertTrue(text.contains("PORT2=8083"))
        XCTAssertTrue(text.contains("PORT3=8083"))
        XCTAssertTrue(text.contains("PORT4=8085"))
    }

    func testVAmigaRPCClientBuildsAndParsesRetroShellRequests() throws {
        let payload = try VAmigaRPCClient.makeRequest(command: "r cpu", id: 42)
        let json = try JSONSerialization.jsonObject(with: payload.data(using: .utf8) ?? Data()) as? [String: Any]

        XCTAssertEqual(json?["jsonrpc"] as? String, "2.0")
        XCTAssertEqual(json?["method"] as? String, "retroshell")
        XCTAssertEqual(json?["params"] as? String, "r cpu")
        XCTAssertEqual(json?["id"] as? Int, 42)

        let response = try VAmigaRPCClient.parseResponse(#"{"jsonrpc":"2.0","result":"PC:00F80000 SR:2700","id":42}"#)
        XCTAssertEqual(response.result, "PC:00F80000 SR:2700")
        XCTAssertNil(response.errorMessage)

        let error = try VAmigaRPCClient.parseResponse(#"{"jsonrpc":"2.0","error":{"code":-32000,"message":"bad command"},"id":42}"#)
        XCTAssertEqual(error.errorMessage, "bad command")
    }

    func testPrometheusParserExtractsRuntimeMetrics() {
        let metrics = VAmigaPrometheusClient.parseMetrics("""
        # TYPE vamiga_cpu_load gauge
        vamiga_cpu_load{component="emulator"} 0.2500

        vamiga_fps{component="emulator"} 49.9200
        vamiga_mem_accesses{component="memory",location="chip_ram",type="write"} 128
        """)

        XCTAssertEqual(metrics["vamiga_cpu_load{component=\"emulator\"}"], 0.25)
        XCTAssertEqual(metrics["vamiga_fps{component=\"emulator\"}"], 49.92)
        XCTAssertEqual(metrics["vamiga_mem_accesses{component=\"memory\",location=\"chip_ram\",type=\"write\"}"], 128)
    }

    func testVAmigaValidationArtifactWriterCreatesStableFiles() throws {
        let tempRoot = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let writer = VAmigaValidationArtifactWriter(rootDirectory: tempRoot.path)
        let record = VAmigaCommandRecord(
            command: "r cpu",
            response: "PC:00F80000 SR:2700",
            timestamp: "2026-05-21T00:00:00Z",
            durationMs: 12,
            parsedRecords: EmulatorService.shared.parseCpuTrace("PC:00F80000 SR:2700"),
            error: nil
        )
        let result = try writer.write(
            runId: "test-run",
            config: VAmigaServerConfig(configPath: "/tmp/vAmiga.ini", backupPath: "/tmp/vAmiga.ini.bak"),
            commands: [record],
            metrics: "vamiga_fps 50.0\n",
            stdoutStderr: "launch ok\n",
            failures: [],
            summary: "Validation passed"
        )

        XCTAssertTrue(FileManager.default.fileExists(atPath: result.artifactDirectory))
        XCTAssertTrue(FileManager.default.fileExists(atPath: result.tracePath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: result.metricsPath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: URL(fileURLWithPath: result.artifactDirectory).appendingPathComponent("manifest.json").path))
        XCTAssertTrue(try String(contentsOfFile: result.tracePath).contains(#""command":"r cpu""#))
        XCTAssertTrue(try String(contentsOfFile: URL(fileURLWithPath: result.artifactDirectory).appendingPathComponent("failure-summary.md").path).contains("Validation passed"))
    }

    // MARK: - VASM Compiler Service Tests

    func testVasmCompilerSuccess() {
        let compiler = CompilerService.shared

        // Ensure vasm exists before running compile test
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            print("Skipping successful compilation test: VASM compiler not found at \(compiler.vasmPath)")
            return
        }

        let validASM = """
                    SECTION Code,CODE
                    XDEF    _Start
        _Start:
                    move.w  #$4000,$dff09a
                    rts
        """

        let expectation = self.expectation(description: "Valid assembly compilation succeeds")

        compiler.compile(assemblyCode: validASM) { success, output in
            XCTAssertTrue(success, "Compilation failed: \(output)")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)
    }

    func testCopperListTemplateCompiles() {
        let compiler = CompilerService.shared

        // Ensure vasm exists before running compile test
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            print("Skipping Copper List compilation test: VASM compiler not found at \(compiler.vasmPath)")
            return
        }

        // Retrieve the Copper Rainbow example
        guard let copperASM = ContentView.examples["Copper Rainbow"] else {
            XCTFail("Copper Rainbow example not found in ContentView.examples")
            return
        }

        // 1. Verify semantic structural requirements are present in the source template
        XCTAssertTrue(copperASM.contains("SECTION    Code,CODE,CHIP"),
                      "Copper list template must target Chip RAM using SECTION CODE,CHIP")

        XCTAssertTrue(copperASM.contains("34(a6)") || copperASM.contains("ActiView"),
                      "Copper list template must preserve the original ActiView from graphics.library")

        XCTAssertTrue(copperASM.contains("EVEN"),
                      "Template must contain EVEN alignment before word/longword variables to prevent Guru Meditation Address Errors (error #80000003)")

        XCTAssertTrue(copperASM.contains("$80(a5)"),
                      "Copper list template must write to COP1LC ($80 offset from custom base) during setup")

        XCTAssertFalse(copperASM.contains("$50(a5)"),
                      "Copper list template should not write to COPCON ($50 offset) for Copper list location")

        // Verify it does not manual-poke COP1LC or COPJMP1 in the restoration block (after waitButton)
        if let exitBlockRange = copperASM.range(of: ".waitButton") {
            let exitBlock = String(copperASM[exitBlockRange.lowerBound...])
            XCTAssertFalse(exitBlock.contains("$80(a5)"), "Should not manually restore COP1LC on exit; use LoadView(oldView) instead")
            XCTAssertFalse(exitBlock.contains("$88(a5)"), "Should not manually strobe COPJMP1 on exit; use LoadView(oldView) instead")
        } else {
            XCTFail("Copper list template must contain a .waitButton loop label")
        }

        // 2. Verify it actually compiles warning-free
        let expectation = self.expectation(description: "Copper Rainbow assembly template compilation succeeds")

        compiler.compile(assemblyCode: copperASM) { success, output in
            XCTAssertTrue(success, "Copper Rainbow template compilation failed with output:\n\(output)")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)
    }

    func testDefaultExampleLibraryContainsTenExamples() {
        XCTAssertEqual(ExampleLibraryStore.defaultExamples.count, 10)
        XCTAssertTrue(ExampleLibraryStore.defaultExamples.contains { $0.language == .assembly })
        XCTAssertTrue(ExampleLibraryStore.defaultExamples.contains { $0.language == .c })
        XCTAssertTrue(ExampleLibraryStore.defaultExamples.contains { $0.language == .mixed })
    }

    func testDefaultAssemblyAndMixedExamplesCompileWithVASM() throws {
        let compiler = CompilerService.shared

        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            XCTFail("VASM compiler not found at \(compiler.vasmPath)")
            return
        }

        for example in ExampleLibraryStore.defaultExamples where example.language != .c {
            let result = try runExampleCompiler(
                executablePath: compiler.vasmPath,
                sourceExtension: "s",
                source: AssemblySourceFormatter.vasmReadySource(from: example.code),
                arguments: { sourceURL, outputURL in
                    [
                        "-kick1hunks",
                        "-Fhunkexe",
                        "-I\(compiler.ndkInclude)",
                        "-o", outputURL.path,
                        "-nosym",
                        sourceURL.path
                    ]
                }
            )

            XCTAssertEqual(
                result.status,
                0,
                "\(example.name) must compile with VASM.\n\(result.output)"
            )
        }
    }

    func testDefaultCExamplesPassClangSyntaxCheck() throws {
        let clangPath = "/usr/bin/clang"
        guard FileManager.default.fileExists(atPath: clangPath) else {
            XCTFail("clang not found at \(clangPath)")
            return
        }

        for example in ExampleLibraryStore.defaultExamples where example.language == .c {
            let result = try runExampleCompiler(
                executablePath: clangPath,
                sourceExtension: "c",
                source: example.code,
                arguments: { sourceURL, _ in
                    [
                        "-std=c89",
                        "-Wall",
                        "-Werror",
                        "-fsyntax-only",
                        sourceURL.path
                    ]
                }
            )

            XCTAssertEqual(
                result.status,
                0,
                "\(example.name) must pass C syntax validation.\n\(result.output)"
            )
        }
    }

    private func runExampleCompiler(
        executablePath: String,
        sourceExtension: String,
        source: String,
        arguments: (URL, URL) -> [String]
    ) throws -> (status: Int32, output: String) {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AmigaPlaygroundExampleTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let sourceURL = tempDirectory.appendingPathComponent("example.\(sourceExtension)")
        let outputURL = tempDirectory.appendingPathComponent("example.bin")
        try source.write(to: sourceURL, atomically: true, encoding: .utf8)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments(sourceURL, outputURL)

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let stdout = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        return (process.terminationStatus, (stdout + "\n" + stderr).trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func testVasmCompilerFailure() {
        let compiler = CompilerService.shared

        // Ensure vasm exists before running compile test
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            print("Skipping failed compilation test: VASM compiler not found at \(compiler.vasmPath)")
            return
        }

        let invalidASM = """
                    SECTION Code,CODE
                    INVALID_INSTRUCTION  #123, d0
                    rts
        """

        let expectation = self.expectation(description: "Invalid assembly compilation fails")

        compiler.compile(assemblyCode: invalidASM) { success, output in
            XCTAssertFalse(success, "Compilation unexpectedly succeeded for invalid assembly")
            XCTAssertTrue(output.contains("error") || output.contains("unknown") || output.contains("fail"), "Output should contain compilation error text")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)
    }

    func testGenerateBootableADF() {
        let compiler = CompilerService.shared

        // Ensure both vasm and xdftool exist before running ADF generation test
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            print("Skipping ADF generation test: VASM compiler not found at \(compiler.vasmPath)")
            return
        }
        guard FileManager.default.fileExists(atPath: compiler.xdftoolPath) else {
            print("Skipping ADF generation test: xdftool not found at \(compiler.xdftoolPath)")
            return
        }

        let validASM = """
                    SECTION Code,CODE
                    XDEF    _Start
        _Start:
                    moveq   #0,d0
                    rts
        """

        let tempDir = FileManager.default.temporaryDirectory
        let targetADF = tempDir.appendingPathComponent("test_playground_generated.adf")

        // Clean up any old test ADF
        try? FileManager.default.removeItem(at: targetADF)

        let expectation = self.expectation(description: "Bootable ADF generation succeeds")

        compiler.generateBootableADF(assemblyCode: validASM, targetADFPath: targetADF.path) { success, output in
            XCTAssertTrue(success, "ADF generation failed with output: \(output)")
            XCTAssertTrue(FileManager.default.fileExists(atPath: targetADF.path), "Target ADF file was not created")

            if let attributes = try? FileManager.default.attributesOfItem(atPath: targetADF.path),
               let size = attributes[.size] as? Int64 {
                // A standard Amiga 3.5" DD disk image is exactly 901,120 bytes
                XCTAssertEqual(size, 901120, "Generated ADF is not of standard double-density Amiga disk size")
            } else {
                XCTFail("Could not read attributes/size of generated ADF file")
            }

            // Clean up
            try? FileManager.default.removeItem(at: targetADF)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0)
    }

    // MARK: - Streaming Parser SSE Tests

    func testOllamaNDJSONStreamingParser() {
        var receivedChunks: [String] = []
        var completedResponse = ""

        let expectation = self.expectation(description: "Ollama NDJSON chunk parsed")

        let delegate = StreamingDelegate(
            onChunk: { chunk in
                receivedChunks.append(chunk)
            },
            onCompletion: { full in
                completedResponse = full
                expectation.fulfill()
            },
            onError: { error in
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        )

        // Mock a standard Ollama JSON chunk
        let sampleNDJSON = """
        {"model":"antigravity-amiga-68k","message":{"role":"assistant","content":"Hello "},"done":false}
        {"model":"antigravity-amiga-68k","message":{"role":"assistant","content":"Amiga!"},"done":true}
        """

        guard let data = sampleNDJSON.data(using: .utf8) else {
            XCTFail("Failed to convert mock NDJSON payload to data")
            return
        }

        // Simulate receive
        delegate.urlSession(URLSession.shared, dataTask: URLSessionDataTask(), didReceive: data)
        delegate.urlSession(URLSession.shared, task: URLSessionDataTask(), didCompleteWithError: nil as Error?)

        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(receivedChunks.count, 2)
        XCTAssertEqual(receivedChunks.first, "Hello ")
        XCTAssertEqual(receivedChunks.last, "Amiga!")
        XCTAssertEqual(completedResponse, "Hello Amiga!")
    }

    func testOpenAISSEStreamingParser() {
        var receivedChunks: [String] = []
        var completedResponse = ""

        let expectation = self.expectation(description: "OpenAI SSE delta chunks parsed")

        let delegate = StreamingDelegate(
            onChunk: { chunk in
                receivedChunks.append(chunk)
            },
            onCompletion: { full in
                completedResponse = full
                expectation.fulfill()
            },
            onError: { error in
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        )

        // Mock standard Server-Sent Events (SSE) data stream payload
        let sampleSSE = """
        data: {"choices":[{"delta":{"content":"Classic "}}]}

        data: {"choices":[{"delta":{"content":"68k"}}]}

        data: [DONE]
        """

        guard let data = sampleSSE.data(using: .utf8) else {
            XCTFail("Failed to convert mock SSE payload to data")
            return
        }

        // Simulate receive
        delegate.urlSession(URLSession.shared, dataTask: URLSessionDataTask(), didReceive: data)
        delegate.urlSession(URLSession.shared, task: URLSessionDataTask(), didCompleteWithError: nil as Error?)

        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(receivedChunks.count, 2)
        XCTAssertEqual(receivedChunks.first, "Classic ")
        XCTAssertEqual(receivedChunks.last, "68k")
        XCTAssertEqual(completedResponse, "Classic 68k")
    }

    func testStreamingDelegateParsesOpenAITokenUsage() {
        var completedUsage: TokenUsage?

        let expectation = self.expectation(description: "OpenAI SSE usage parsed")

        let delegate = StreamingDelegate(
            onContentChunk: { _ in },
            onReasoningChunk: { _ in },
            onCompletion: { _, _, usage in
                completedUsage = usage
                expectation.fulfill()
            },
            onError: { error in
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        )

        let sampleSSE = """
        data: {"choices":[{"delta":{"content":"Classic 68k"}}]}
        data: {"choices":[],"usage":{"prompt_tokens":123,"completion_tokens":45,"total_tokens":168}}
        data: [DONE]
        """

        delegate.urlSession(URLSession.shared, dataTask: URLSessionDataTask(), didReceive: Data(sampleSSE.utf8))
        delegate.urlSession(URLSession.shared, task: URLSessionDataTask(), didCompleteWithError: nil as Error?)

        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(completedUsage, TokenUsage(inputTokens: 123, outputTokens: 45, totalTokens: 168))
    }

    func testStreamingDelegateParsesOllamaTokenUsage() {
        var completedUsage: TokenUsage?

        let expectation = self.expectation(description: "Ollama usage parsed")

        let delegate = StreamingDelegate(
            onContentChunk: { _ in },
            onReasoningChunk: { _ in },
            onCompletion: { _, _, usage in
                completedUsage = usage
                expectation.fulfill()
            },
            onError: { error in
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        )

        let sampleNDJSON = """
        {"model":"antigravity-amiga-68k","message":{"role":"assistant","content":"Hello"},"done":false}
        {"model":"antigravity-amiga-68k","done":true,"prompt_eval_count":88,"eval_count":22}
        """

        delegate.urlSession(URLSession.shared, dataTask: URLSessionDataTask(), didReceive: Data(sampleNDJSON.utf8))
        delegate.urlSession(URLSession.shared, task: URLSessionDataTask(), didCompleteWithError: nil as Error?)

        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(completedUsage, TokenUsage(inputTokens: 88, outputTokens: 22, totalTokens: 110))
    }

    func testOpenAISSEStreamingParserStripsNulControlCharacters() {
        var receivedChunks: [String] = []
        var completedResponse = ""

        let expectation = self.expectation(description: "NUL control characters stripped from SSE chunks")

        let delegate = StreamingDelegate(
            onChunk: { chunk in
                receivedChunks.append(chunk)
            },
            onCompletion: { full in
                completedResponse = full
                expectation.fulfill()
            },
            onError: { error in
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        )

        let sampleSSE = """
        data: {"choices":[{"delta":{"content":"\\u0000SECTION Code,CODE,CHIP\\n"}}]}

        data: {"choices":[{"delta":{"content":"Copper\\u0000List"}}]}

        data: [DONE]
        """

        delegate.urlSession(URLSession.shared, dataTask: URLSessionDataTask(), didReceive: Data(sampleSSE.utf8))
        delegate.urlSession(URLSession.shared, task: URLSessionDataTask(), didCompleteWithError: nil as Error?)

        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(receivedChunks, ["SECTION Code,CODE,CHIP\n", "CopperList"])
        XCTAssertEqual(completedResponse, "SECTION Code,CODE,CHIP\nCopperList")
    }

    func testOpenAISSEStreamingParserBuffersFragmentedLines() {
        var receivedChunks: [String] = []
        var completedResponse = ""

        let expectation = self.expectation(description: "Fragmented SSE chunks parsed")

        let delegate = StreamingDelegate(
            onChunk: { chunk in
                receivedChunks.append(chunk)
            },
            onCompletion: { full in
                completedResponse = full
                expectation.fulfill()
            },
            onError: { error in
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        )

        let firstChunk = #"data: {"choices":[{"delta":{"content":"Copper "}}"#
        let secondChunk = """
        ]}
        data: {"choices":[{"delta":{"content":"list"}}]}

        """

        delegate.urlSession(URLSession.shared, dataTask: URLSessionDataTask(), didReceive: Data(firstChunk.utf8))
        delegate.urlSession(URLSession.shared, dataTask: URLSessionDataTask(), didReceive: Data(secondChunk.utf8))
        delegate.urlSession(URLSession.shared, task: URLSessionDataTask(), didCompleteWithError: nil as Error?)

        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(receivedChunks, ["Copper ", "list"])
        XCTAssertEqual(completedResponse, "Copper list")
    }

    func testOpenAISSEReasoningStreamingParser() {
        var receivedChunks: [String] = []
        var completedResponse = ""

        let expectation = self.expectation(description: "OpenAI SSE reasoning chunks parsed")

        let delegate = StreamingDelegate(
            onChunk: { chunk in
                receivedChunks.append(chunk)
            },
            onCompletion: { full in
                completedResponse = full
                expectation.fulfill()
            },
            onError: { error in
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        )

        // Mock OpenAI SSE reasoning payload
        let sampleSSE = """
        data: {"choices":[{"delta":{"reasoning":"Thinking "}}]}

        data: {"choices":[{"delta":{"reasoning":"process"}}]}

        data: [DONE]
        """

        guard let data = sampleSSE.data(using: .utf8) else {
            XCTFail("Failed to convert mock SSE payload to data")
            return
        }

        // Simulate receive
        delegate.urlSession(URLSession.shared, dataTask: URLSessionDataTask(), didReceive: data)
        delegate.urlSession(URLSession.shared, task: URLSessionDataTask(), didCompleteWithError: nil as Error?)

        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(receivedChunks.count, 2)
        XCTAssertEqual(receivedChunks.first, "Thinking ")
        XCTAssertEqual(receivedChunks.last, "process")
        XCTAssertEqual(completedResponse, "Thinking process")
    }

    func testOpenAIMessageStreamingParser() {
        var receivedChunks: [String] = []
        var completedResponse = ""

        let expectation = self.expectation(description: "OpenAI message content parsed")

        let delegate = StreamingDelegate(
            onChunk: { chunk in
                receivedChunks.append(chunk)
            },
            onCompletion: { full in
                completedResponse = full
                expectation.fulfill()
            },
            onError: { error in
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        )

        let payload = """
        data: {"choices":[{"message":{"content":"Generated 68k source"}}]}

        """

        delegate.urlSession(URLSession.shared, dataTask: URLSessionDataTask(), didReceive: Data(payload.utf8))
        delegate.urlSession(URLSession.shared, task: URLSessionDataTask(), didCompleteWithError: nil as Error?)

        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(receivedChunks, ["Generated 68k source"])
        XCTAssertEqual(completedResponse, "Generated 68k source")
    }

    func testOpenAISSEContentAndReasoningStreamingParser() {
        var receivedContent: [String] = []
        var receivedReasoning: [String] = []
        var completedContent = ""
        var completedReasoning = ""

        let expectation = self.expectation(description: "OpenAI SSE content and reasoning chunks parsed separately")

        let delegate = StreamingDelegate(
            onContentChunk: { chunk in
                receivedContent.append(chunk)
            },
            onReasoningChunk: { chunk in
                receivedReasoning.append(chunk)
            },
            onCompletion: { content, reasoning in
                completedContent = content
                completedReasoning = reasoning
                expectation.fulfill()
            },
            onError: { error in
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        )

        // Mock OpenAI SSE combined content and reasoning payload
        let sampleSSE = """
        data: {"choices":[{"delta":{"reasoning":"Thinking "}}]}
        data: {"choices":[{"delta":{"reasoning":"process"}}]}
        data: {"choices":[{"delta":{"content":"Hello "}}]}
        data: {"choices":[{"delta":{"content":"World!"}}]}
        data: [DONE]
        """

        guard let data = sampleSSE.data(using: .utf8) else {
            XCTFail("Failed to convert mock SSE payload to data")
            return
        }

        delegate.urlSession(URLSession.shared, dataTask: URLSessionDataTask(), didReceive: data)
        delegate.urlSession(URLSession.shared, task: URLSessionDataTask(), didCompleteWithError: nil as Error?)

        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(receivedReasoning, ["Thinking ", "process"])
        XCTAssertEqual(receivedContent, ["Hello ", "World!"])
        XCTAssertEqual(completedReasoning, "Thinking process")
        XCTAssertEqual(completedContent, "Hello World!")
    }

    // MARK: - Ollama/LM Studio Service Tests

    func testOllamaServiceDefaultsToLocalMLXServer() {
        let service = OllamaService()

        XCTAssertEqual(service.provider, .lmStudio)
        XCTAssertEqual(service.apiUrl, "http://localhost:1234")
        XCTAssertEqual(service.modelName, "bmove/antigravity-amiga-68k")
        XCTAssertEqual(service.requestModelName, "default_model")
        XCTAssertEqual(service.connectionStatusLabel, "LM Studio Not Checked")
    }

    func testOllamaServiceApiUrl() {
        let service = OllamaService.shared

        // Save existing state to restore it later
        let originalProvider = service.provider
        let originalCustomUrl = service.customUrl
        let originalModelName = service.modelName

        // Test Default Ollama URL
        service.provider = .ollama
        service.customUrl = ""
        XCTAssertEqual(service.apiUrl, "http://localhost:11434")

        // Test Default LM Studio URL
        service.provider = .lmStudio
        service.customUrl = ""
        XCTAssertEqual(service.apiUrl, "http://localhost:1234")

        // Test Custom URL overrides provider default
        service.customUrl = "http://my-local-llm:8080"
        XCTAssertEqual(service.apiUrl, "http://my-local-llm:8080")

        // Restore state
        service.provider = originalProvider
        service.customUrl = originalCustomUrl
        service.modelName = originalModelName
    }

    func testOllamaServiceRequestModelNameUsesMLXDefaultModel() {
        let service = OllamaService.shared

        let originalProvider = service.provider
        let originalModelName = service.modelName

        service.provider = .lmStudio
        service.modelName = "bmove/antigravity-amiga-68k"
        XCTAssertEqual(service.requestModelName, "default_model")

        service.modelName = "antigravity-amiga-68k"
        XCTAssertEqual(service.requestModelName, "default_model")

        service.modelName = ""
        XCTAssertEqual(service.requestModelName, "default_model")

        service.modelName = "custom-local-model"
        XCTAssertEqual(service.requestModelName, "custom-local-model")

        service.provider = originalProvider
        service.modelName = originalModelName
    }

    func testOllamaServiceMarksLMStudioConnectedOnlyAfterHealthCheckSucceeds() {
        let service = OllamaService()
        service.provider = .lmStudio
        service.customUrl = "http://local-mlx.test"
        service.modelName = "mlx-community/antigravity"

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockLLMURLProtocol.self]
        service.urlSessionConfiguration = configuration

        let expectation = self.expectation(description: "Connection status updated")

        MockLLMURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "http://local-mlx.test/v1/models")
            let response = try XCTUnwrap(HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            ))
            return (response, Data(#"{"data":[{"id":"mlx-community/antigravity"}]}"#.utf8))
        }

        service.refreshConnectionStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(service.connectionStatus, .connected)
            XCTAssertEqual(service.connectionStatusLabel, "LM Studio Connected")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
        MockLLMURLProtocol.requestHandler = nil
    }

    func testOllamaServiceMarksLMStudioConnectedWhenConfiguredModelIsMissing() {
        let service = OllamaService()
        service.provider = .lmStudio
        service.customUrl = "http://local-mlx.test"
        service.modelName = "missing-model"

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockLLMURLProtocol.self]
        service.urlSessionConfiguration = configuration

        let expectation = self.expectation(description: "Connected status updated")

        MockLLMURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "http://local-mlx.test/v1/models")
            let response = try XCTUnwrap(HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            ))
            return (response, Data(#"{"data":[{"id":"available-model"}]}"#.utf8))
        }

        service.refreshConnectionStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(service.connectionStatus, .connected)
            XCTAssertEqual(service.connectionStatusLabel, "LM Studio Connected")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
        MockLLMURLProtocol.requestHandler = nil
    }

    func testOllamaServiceMarksProviderDisconnectedWhenHealthCheckFails() {
        let service = OllamaService()
        service.provider = .ollama
        service.customUrl = "http://local-ollama.test"

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockLLMURLProtocol.self]
        service.urlSessionConfiguration = configuration

        let expectation = self.expectation(description: "Disconnected status updated")

        MockLLMURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "http://local-ollama.test/api/tags")
            let response = try XCTUnwrap(HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 503,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            ))
            return (response, Data())
        }

        service.refreshConnectionStatus()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(service.connectionStatus, .disconnected("HTTP 503"))
            XCTAssertEqual(service.connectionStatusLabel, "Ollama Not Connected")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
        MockLLMURLProtocol.requestHandler = nil
    }

    func testOllamaServiceSendsOpenAICompatibleRequestAndParsesResponse() {
        let defaultsName = "AmigaPlaygroundTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: defaultsName)!
        defer { defaults.removePersistentDomain(forName: defaultsName) }

        let service = OllamaService(userDefaults: defaults)
        service.provider = .lmStudio
        service.customUrl = "http://local-mlx.test"
        service.modelName = ""
        service.contextWindow = 4096
        service.systemPrompt = ""

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockLLMURLProtocol.self]
        service.urlSessionConfiguration = configuration

        let expectedPrompt = "write a custom animated copper list"
        let expectation = self.expectation(description: "Mock LLM response parsed")
        var receivedChunks: [String] = []
        var completedResponse = ""

        MockLLMURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "http://local-mlx.test/v1/chat/completions")
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")

            let bodyData = try XCTUnwrap(request.testHTTPBodyData)
            let body = try XCTUnwrap(JSONSerialization.jsonObject(with: bodyData) as? [String: Any])
            XCTAssertEqual(body["model"] as? String, "default_model")
            XCTAssertEqual(body["stream"] as? Bool, true)
            XCTAssertEqual(body["max_tokens"] as? Int, 4096)

            let messages = try XCTUnwrap(body["messages"] as? [[String: String]])
            XCTAssertEqual(messages, [
                ["role": "system", "content": OllamaService.generationContractPrompt],
                ["role": "user", "content": expectedPrompt]
            ])

            let response = try XCTUnwrap(HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "text/event-stream"]
            ))
            let data = Data("""
            data: {"choices":[{"delta":{"content":"SECTION Code,CODE,CHIP\\n"}}]}
            data: {"choices":[{"delta":{"content":"CopperList:\\n    dc.w $ffff,$fffe"}}]}
            data: [DONE]

            """.utf8)
            return (response, data)
        }

        service.streamChat(
            messages: [OllamaService.ChatMessage(role: "user", content: expectedPrompt)],
            onChunk: { chunk in
                receivedChunks.append(chunk)
            },
            onCompletion: { fullResponse in
                completedResponse = fullResponse
                expectation.fulfill()
            },
            onError: { error in
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 2.0)

        XCTAssertEqual(receivedChunks, [
            "SECTION Code,CODE,CHIP\n",
            "CopperList:\n    dc.w $ffff,$fffe"
        ])
        XCTAssertEqual(completedResponse, "SECTION Code,CODE,CHIP\nCopperList:\n    dc.w $ffff,$fffe")
        MockLLMURLProtocol.requestHandler = nil
    }

    func testOllamaServiceSendsAdapterPathToOpenAICompatibleProvider() {
        let defaultsName = "AmigaPlaygroundTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: defaultsName)!
        defer { defaults.removePersistentDomain(forName: defaultsName) }

        let service = OllamaService(userDefaults: defaults)
        service.provider = .lmStudio
        service.customUrl = "http://local-mlx.test"
        service.modelName = ""
        service.systemPrompt = ""

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockLLMURLProtocol.self]
        service.urlSessionConfiguration = configuration

        let expectation = self.expectation(description: "OpenAI-compatible request includes adapter")

        MockLLMURLProtocol.requestHandler = { request in
            let bodyData = try XCTUnwrap(request.testHTTPBodyData)
            let body = try XCTUnwrap(JSONSerialization.jsonObject(with: bodyData) as? [String: Any])

            XCTAssertEqual(body["model"] as? String, "default_model")
            XCTAssertEqual(body["adapters"] as? String, "adapters_asm")

            let response = try XCTUnwrap(HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "text/event-stream"]
            ))
            return (response, Data("data: [DONE]\n\n".utf8))
        }

        service.streamChat(
            messages: [OllamaService.ChatMessage(role: "user", content: "draw a copper gradient")],
            adapterPath: "adapters_asm",
            onChunk: { _ in },
            onCompletion: { _ in expectation.fulfill() },
            onError: { error in
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 2.0)
        MockLLMURLProtocol.requestHandler = nil
    }

    func testOllamaServiceSendsSystemPromptAndContextWindowToOpenAICompatibleProvider() {
        let defaultsName = "AmigaPlaygroundTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: defaultsName)!
        defer { defaults.removePersistentDomain(forName: defaultsName) }

        let service = OllamaService(userDefaults: defaults)
        service.provider = .lmStudio
        service.customUrl = "http://local-mlx.test"
        service.modelName = "mlx-community/antigravity"
        service.contextWindow = 8192
        service.systemPrompt = "  Keep answers focused on Amiga 68k assembly.  "

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockLLMURLProtocol.self]
        service.urlSessionConfiguration = configuration

        let expectation = self.expectation(description: "OpenAI-compatible request includes AI settings")

        MockLLMURLProtocol.requestHandler = { request in
            let bodyData = try XCTUnwrap(request.testHTTPBodyData)
            let body = try XCTUnwrap(JSONSerialization.jsonObject(with: bodyData) as? [String: Any])

            XCTAssertEqual(body["max_tokens"] as? Int, 8192)

            let messages = try XCTUnwrap(body["messages"] as? [[String: String]])
            XCTAssertEqual(messages, [
                ["role": "system", "content": "Keep answers focused on Amiga 68k assembly."],
                ["role": "system", "content": OllamaService.generationContractPrompt],
                ["role": "user", "content": "draw a copper gradient"]
            ])

            let response = try XCTUnwrap(HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "text/event-stream"]
            ))
            return (response, Data("data: [DONE]\n\n".utf8))
        }

        service.streamChat(
            messages: [OllamaService.ChatMessage(role: "user", content: "draw a copper gradient")],
            onChunk: { _ in },
            onCompletion: { _ in expectation.fulfill() },
            onError: { error in
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 2.0)
        MockLLMURLProtocol.requestHandler = nil
    }

    func testOllamaServiceSendsSystemPromptAndContextWindowToOllamaProvider() {
        let defaultsName = "AmigaPlaygroundTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: defaultsName)!
        defer { defaults.removePersistentDomain(forName: defaultsName) }

        let service = OllamaService(userDefaults: defaults)
        service.provider = .ollama
        service.customUrl = "http://local-ollama.test"
        service.modelName = "antigravity-amiga-68k"
        service.contextWindow = 2048
        service.systemPrompt = "Prefer concise code."

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockLLMURLProtocol.self]
        service.urlSessionConfiguration = configuration

        let expectation = self.expectation(description: "Ollama request includes AI settings")

        MockLLMURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "http://local-ollama.test/api/chat")

            let bodyData = try XCTUnwrap(request.testHTTPBodyData)
            let body = try XCTUnwrap(JSONSerialization.jsonObject(with: bodyData) as? [String: Any])

            let options = try XCTUnwrap(body["options"] as? [String: Any])
            XCTAssertEqual(options["num_ctx"] as? Int, 2048)

            let messages = try XCTUnwrap(body["messages"] as? [[String: String]])
            XCTAssertEqual(messages, [
                ["role": "system", "content": "Prefer concise code."],
                ["role": "system", "content": OllamaService.generationContractPrompt],
                ["role": "user", "content": "read joystick state"]
            ])

            let response = try XCTUnwrap(HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/x-ndjson"]
            ))
            return (response, Data(#"{"done":true}"#.utf8))
        }

        service.streamChat(
            messages: [OllamaService.ChatMessage(role: "user", content: "read joystick state")],
            onChunk: { _ in },
            onCompletion: { _ in expectation.fulfill() },
            onError: { error in
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        )

        waitForExpectations(timeout: 2.0)
        MockLLMURLProtocol.requestHandler = nil
    }

    // MARK: - MLX Server Control Tests

    func testMLXHelperTargetExistsInPackageManifest() throws {
        let packageURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Package.swift")
        let packageText = try String(contentsOf: packageURL)

        XCTAssertTrue(packageText.contains(#"name: "MLXServerHelper""#))
        XCTAssertTrue(packageText.contains(#"path: "Helpers/MLXServerHelper""#))
    }

    func testMLXHelperInvocationBuildsExpectedArguments() {
        let config = MLXServerController.Configuration(
            workingDirectory: URL(fileURLWithPath: "/tmp/fine_tuning", isDirectory: true),
            modelDirectoryName: "fused_model",
            port: 1234,
            logFileName: "server.log"
        )

        let invocation = MLXServerController.buildInvocation(configuration: config)

        XCTAssertEqual(invocation.arguments, [
            "--model", "/tmp/fine_tuning/fused_model",
            "--port", "1234",
            "--log-file", "/tmp/fine_tuning/server.log",
            "--runtime-command", "uv run python -m mlx_lm.server"
        ])
    }

    func testMLXHelperFailureMessageIncludesSetupAction() throws {
        let line = #"{"event":"failed","message":"uv was not found.","code":"missing_uv","action":"Install uv with `curl -LsSf https://astral.sh/uv/install.sh | sh`, then restart Amiga Playground. If uv is already installed, make sure it is available at /opt/homebrew/bin/uv, /usr/local/bin/uv, or ~/.local/bin/uv."}"#

        let status = try MLXServerController.HelperStatus.parse(line: line)

        XCTAssertEqual(status.event, .failed)
        XCTAssertEqual(status.code, "missing_uv")
        XCTAssertEqual(status.message, "uv was not found.")
        XCTAssertTrue(status.action?.contains("Install uv") == true)
    }

    func testMLXServerBuildsExpectedLaunchInvocation() throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let modelDirectory = tempDirectory.appendingPathComponent("fused_model", isDirectory: true)
        try FileManager.default.createDirectory(at: modelDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let config = MLXServerController.Configuration(
            workingDirectory: tempDirectory,
            modelDirectoryName: "fused_model",
            port: 1234,
            logFileName: "server.log"
        )

        let invocation = MLXServerController.buildInvocation(configuration: config)

        XCTAssertEqual(invocation.executableURL.lastPathComponent, "MLXServerHelper")
        XCTAssertEqual(invocation.arguments, [
            "--model", tempDirectory.appendingPathComponent("fused_model").path,
            "--port", "1234",
            "--log-file", tempDirectory.appendingPathComponent("server.log").path,
            "--runtime-command", "uv run python -m mlx_lm.server"
        ])
        XCTAssertEqual(invocation.workingDirectory, tempDirectory)
        XCTAssertEqual(invocation.logFile, tempDirectory.appendingPathComponent("server.log"))
    }

    func testMLXServerStartFailsWhenModelDirectoryIsMissing() {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let controller = MLXServerController(
            configuration: MLXServerController.Configuration(
                workingDirectory: tempDirectory,
                modelDirectoryName: "fused_model",
                port: 1234,
                logFileName: "server.log"
            )
        )

        controller.start()

        guard case .failed(let message) = controller.status else {
            XCTFail("Expected missing model directory to fail startup.")
            return
        }

        XCTAssertTrue(message.contains("fused_model"))
    }

    func testMLXModelDownloadManifestContainsAppCompatibleAdapter() {
        let paths = MLXServerController.modelDownloadFiles.map(\.relativePath)

        XCTAssertTrue(paths.contains("model.safetensors"))
        XCTAssertTrue(paths.contains("tokenizer.json"))
        XCTAssertTrue(paths.contains("adapters_asm/adapter_config.json"))
        XCTAssertTrue(paths.contains("adapters_asm/adapters.safetensors"))
        XCTAssertTrue(paths.contains("adapters_c/adapter_config.json"))
        XCTAssertTrue(paths.contains("adapters_c/adapters.safetensors"))
        XCTAssertTrue(
            MLXServerController.modelDownloadFiles
                .allSatisfy { $0.remoteURL.absoluteString.hasPrefix("https://huggingface.co/bmove/antigravity-amiga-68k/resolve/main/") }
        )
    }

    func testMLXServerResolvesAdapterPathInsideModelDirectory() {
        let controller = MLXServerController(
            configuration: MLXServerController.Configuration(
                workingDirectory: URL(fileURLWithPath: "/tmp/fine_tuning", isDirectory: true),
                modelDirectoryName: "fused_model",
                port: 1234,
                logFileName: "server.log"
            )
        )

        XCTAssertEqual(
            controller.adapterDirectory(named: "adapters_asm").path,
            "/tmp/fine_tuning/fused_model/adapters_asm"
        )
    }

    func testMLXModelDownloadedDetectionRequiresModelAndAdapters() throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let controller = MLXServerController(
            configuration: MLXServerController.Configuration(
                workingDirectory: tempDirectory,
                modelDirectoryName: "fused_model",
                port: 1234,
                logFileName: "server.log"
            )
        )

        XCTAssertFalse(controller.modelIsDownloaded)
        for path in [
            "config.json",
            "model.safetensors",
            "tokenizer.json",
            "adapters_asm/adapters.safetensors",
            "adapters_c/adapters.safetensors"
        ] {
            let url = controller.modelDirectory.appendingPathComponent(path)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try Data().write(to: url)
        }

        XCTAssertTrue(controller.modelIsDownloaded)
    }
}

private extension URLRequest {
    var testHTTPBodyData: Data? {
        if let httpBody {
            return httpBody
        }

        guard let httpBodyStream else {
            return nil
        }

        httpBodyStream.open()
        defer { httpBodyStream.close() }

        var data = Data()
        let bufferSize = 1024
        var buffer = [UInt8](repeating: 0, count: bufferSize)

        while httpBodyStream.hasBytesAvailable {
            let read = httpBodyStream.read(&buffer, maxLength: bufferSize)
            if read > 0 {
                data.append(buffer, count: read)
            } else {
                break
            }
        }

        return data
    }
}

private final class MockLLMURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        do {
            guard let handler = Self.requestHandler else {
                throw NSError(domain: "MockLLMURLProtocol", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing request handler"])
            }

            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
