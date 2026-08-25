import XCTest
@testable import AmigaPlayground

class AmigaPlaygroundTests: XCTestCase {

    func testChatBoingBallPreferenceDefaultsVisible() {
        XCTAssertEqual(AppPreferenceDefaults.showChatBoingBallKey, "showChatBoingBall")
        XCTAssertTrue(AppPreferenceDefaults.showChatBoingBall)
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

    func testAssistantChatSessionDoesNotInjectConnectionErrorContainingAmigaTokens() {
        let session = AssistantChatSession()
        _ = session.submit("write a custom animated copper list")

        let response = """
        +------------------------------------------------------------(0)
        .ankey
        +------------------------------------------------------------(0)
        .copper
        * Connection Error: model 'amiga-playground-asm' not found
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
            "/tmp/session.retrosh",
            "-help",
            "--debug"
        ])
    }

    func testBuildVAmigaInvocationUsesOpenForAppBundleContext() {
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
            "/tmp/session.retrosh",
            "--args",
            "--debug"
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
        XCTAssertTrue(script.contains("try df0 insert \"/tmp/test.adf\""))
        XCTAssertTrue(script.contains("try amiga run"))
        XCTAssertTrue(script.contains("try run"))
        XCTAssertTrue(script.contains("regs"))
        XCTAssertTrue(script.contains("disassemble"))
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
        XCTAssertTrue(text.contains("AUTORUN0=1"))
        XCTAssertTrue(text.contains("AUTORUN1=1"))
        XCTAssertTrue(text.contains("AUTORUN3=1"))
        XCTAssertTrue(text.contains("AUTORUN4=1"))
        XCTAssertTrue(text.contains("PORT0=8080"))
        XCTAssertTrue(text.contains("PORT1=8081"))
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

        // Ensure both vasm and send2adf exist before running ADF generation test
        guard FileManager.default.fileExists(atPath: compiler.vasmPath) else {
            print("Skipping ADF generation test: VASM compiler not found at \(compiler.vasmPath)")
            return
        }
        guard FileManager.default.fileExists(atPath: compiler.send2adfPath) else {
            print("Skipping ADF generation test: send2adf not found at \(compiler.send2adfPath)")
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
        {"model":"amiga-playground-asm","message":{"role":"assistant","content":"Hello "},"done":false}
        {"model":"amiga-playground-asm","message":{"role":"assistant","content":"Amiga!"},"done":true}
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
        XCTAssertEqual(service.requestModelName, "amiga-playground-asm")
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

    func testOllamaServiceRequestModelNameUsesPlaygroundAsmId() {
        let service = OllamaService.shared

        let originalProvider = service.provider
        let originalModelName = service.modelName

        service.provider = .lmStudio
        service.modelName = "amiga-playground-asm"
        XCTAssertEqual(service.requestModelName, "amiga-playground-asm")

        service.modelName = ""
        XCTAssertEqual(service.requestModelName, "amiga-playground-asm")

        service.modelName = "custom-local-model"
        XCTAssertEqual(service.requestModelName, "custom-local-model")

        // Retired ids must never leave the machine as the request model.
        service.modelName = "default_model"
        XCTAssertEqual(service.requestModelName, "amiga-playground-asm")
        service.modelName = "antigravity-amiga-68k"
        XCTAssertEqual(service.requestModelName, "amiga-playground-asm")

        service.provider = originalProvider
        service.modelName = originalModelName
    }

    func testOllamaServiceMigratesLegacyStoredModelName() {
        let suiteName = "OllamaService.migrate.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.set("default_model", forKey: OllamaService.PreferenceKey.modelName)

        let service = OllamaService(userDefaults: defaults)
        XCTAssertEqual(service.modelName, "amiga-playground-asm")
        XCTAssertEqual(service.requestModelName, "amiga-playground-asm")
        XCTAssertEqual(defaults.string(forKey: OllamaService.PreferenceKey.modelName), "amiga-playground-asm")
    }

    func testOllamaServiceApplyPlaygroundConnectionDefaults() {
        let suiteName = "OllamaService.playgroundDefaults.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let service = OllamaService(userDefaults: defaults)

        service.provider = .ollama
        service.customUrl = "http://somewhere:9"
        service.modelName = "default_model"

        XCTAssertFalse(service.isUsingPlaygroundConnection)

        service.applyPlaygroundConnectionDefaults()

        XCTAssertEqual(service.provider, .lmStudio)
        XCTAssertEqual(service.customUrl, "")
        XCTAssertEqual(service.modelName, "amiga-playground-asm")
        XCTAssertEqual(service.requestModelName, "amiga-playground-asm")
        XCTAssertTrue(service.isUsingPlaygroundModel)
        XCTAssertTrue(service.isUsingPlaygroundConnection)
    }

    func testOllamaServiceMigrateLegacyModelNameIfNeededRewritesUIField() {
        let suiteName = "OllamaService.migrateUI.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let service = OllamaService(userDefaults: defaults)
        service.modelName = "default_model"

        // requestModelName already rewrites, but the UI field should also be cleaned up.
        XCTAssertTrue(service.migrateLegacyModelNameIfNeeded())
        XCTAssertEqual(service.modelName, "amiga-playground-asm")
        XCTAssertFalse(service.migrateLegacyModelNameIfNeeded())
    }

    func testOllamaServiceMarksLMStudioConnectedOnlyAfterHealthCheckSucceeds() {
        let service = OllamaService()
        service.provider = .lmStudio
        service.customUrl = "http://local-mlx.test"
        service.modelName = "amiga-playground-asm"

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
            return (response, Data(#"{"data":[{"id":"amiga-playground-asm"}]}"#.utf8))
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
            XCTAssertEqual(body["model"] as? String, "amiga-playground-asm")
            XCTAssertEqual(body["stream"] as? Bool, true)
            XCTAssertEqual(body["max_tokens"] as? Int, 4096)

            let messages = try XCTUnwrap(body["messages"] as? [[String: String]])
            XCTAssertEqual(messages, [["role": "user", "content": expectedPrompt]])

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

    func testOllamaServiceSendsSystemPromptAndContextWindowToOpenAICompatibleProvider() {
        let defaultsName = "AmigaPlaygroundTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: defaultsName)!
        defer { defaults.removePersistentDomain(forName: defaultsName) }

        let service = OllamaService(userDefaults: defaults)
        service.provider = .lmStudio
        service.customUrl = "http://local-mlx.test"
        service.modelName = "amiga-playground-asm"
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
        service.modelName = "amiga-playground-asm"
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

    func testMLXServerBuildsExpectedLaunchInvocation() throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let modelDirectory = tempDirectory.appendingPathComponent("runtime/base", isDirectory: true)
        try FileManager.default.createDirectory(at: modelDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let config = MLXServerController.Configuration(
            workingDirectory: tempDirectory,
            modelDirectoryName: "runtime/base",
            adapterDirectoryName: "runtime/adapter",
            modelId: "amiga-playground-asm",
            port: 1234,
            logFileName: "server.log"
        )

        let invocation = MLXServerController.buildInvocation(configuration: config)

        XCTAssertEqual(invocation.executableURL.path, "/bin/zsh")
        XCTAssertEqual(invocation.arguments, [
            "-lc",
            "cd '\(tempDirectory.path)' && exec uv run python serve_playground.py --model 'runtime/base' --adapter-path 'runtime/adapter' --port '1234'"
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
                modelDirectoryName: "runtime/base",
                adapterDirectoryName: "runtime/adapter",
                modelId: "amiga-playground-asm",
                port: 1234,
                logFileName: "server.log"
            )
        )

        controller.start()

        guard case .failed(let message) = controller.status else {
            XCTFail("Expected missing model directory to fail startup.")
            return
        }

        XCTAssertTrue(message.contains("runtime/base"))
    }

    // MARK: - Tutorial Catalog

    func testTutorialCatalogParsesIndexJSON() throws {
        let json = """
        {
          "version": 1,
          "tutorials": [
            {
              "id": "copper-rainbow-bars",
              "title": "Copper Rainbow Bars",
              "summary": "Color bands",
              "file": "copper-rainbow-bars.s",
              "language": "assembly",
              "order": 1
            },
            {
              "id": "read-the-joystick",
              "title": "Read the Joystick",
              "file": "joystick-reader.s",
              "order": 2
            }
          ]
        }
        """.data(using: .utf8)!

        let entries = try TutorialCatalogService.parseIndexJSON(json)
        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries[0].title, "Copper Rainbow Bars")
        XCTAssertEqual(entries[0].file, "copper-rainbow-bars.s")
        XCTAssertEqual(entries[0].language, "assembly")
        XCTAssertEqual(entries[1].title, "Read the Joystick")
        XCTAssertEqual(entries[1].language, "assembly")
    }

    func testTutorialHumanTitleFromFileName() {
        XCTAssertEqual(
            TutorialCatalogService.humanTitle(forFileName: "copper-rainbow-bars.s"),
            "Copper Rainbow Bars"
        )
        XCTAssertEqual(
            TutorialCatalogService.humanTitle(forFileName: "read_the_joystick.asm"),
            "Read The Joystick"
        )
        XCTAssertTrue(TutorialCatalogService.isSourceFile("demo.s"))
        XCTAssertFalse(TutorialCatalogService.isSourceFile("index.json"))
        XCTAssertFalse(TutorialCatalogService.isSourceFile("README.md"))
    }

    func testBundledTutorialSourcesExistAndLookLikeCode() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // AmigaPlaygroundTests
            .deletingLastPathComponent() // AmigaPlayground
            .appendingPathComponent("tutorials", isDirectory: true)
        let indexURL = root.appendingPathComponent("index.json")
        let data = try Data(contentsOf: indexURL)
        let entries = try TutorialCatalogService.parseIndexJSON(data)
        XCTAssertFalse(entries.isEmpty)

        for entry in entries {
            let sourceURL = root.appendingPathComponent(entry.file)
            let code = try String(contentsOf: sourceURL, encoding: .utf8)
            XCTAssertFalse(code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, entry.file)
            XCTAssertFalse(code.contains("<html"), "\(entry.file) must not be HTML")
            XCTAssertFalse(code.contains("```"), "\(entry.file) must not be Markdown fenced code")
        }
    }

    func testAssemblyCourseParsesLessonsAndQuizContract() throws {
        let json = Data("""
        {
          "id": "amiga-68000",
          "title": "Amiga 68000 Assembly School",
          "subtitle": "Learn by editing and running real code.",
          "lessons": [
            {
              "id": "move",
              "title": "MOVE: your first instruction",
              "subtitle": "Constants, registers, and sizes",
              "tag": "Simulator",
              "goal": "Make D0 contain 42.",
              "theory": ["MOVE copies data."],
              "analogy": "A register is an explicit variable.",
              "keyIdea": "The destination is on the right.",
              "starterCode": "moveq #42,d0\\nrts",
              "quiz": {
                "question": "What does MOVE do?",
                "options": ["Copy", "Jump"],
                "answer": 0,
                "feedback": "MOVE copies the source value."
              }
            }
          ]
        }
        """.utf8)

        let course = try AssemblyCourseCatalog.parse(json)

        XCTAssertEqual(course.id, "amiga-68000")
        XCTAssertEqual(course.lessons.count, 1)
        XCTAssertEqual(course.lessons[0].starterCode, "moveq #42,d0\nrts")
        XCTAssertEqual(course.lessons[0].quiz.answer, 0)
    }

    func testAssemblyLessonLoadStateOnlyTargetsTheEditor() {
        let lesson = AssemblyLesson(
            id: "move",
            title: "MOVE: your first instruction",
            subtitle: "Constants, registers, and sizes",
            tag: "Practice",
            goal: "Make D0 contain 42.",
            emulatorPresetID: "a500-kickstart-13",
            emulatorPresetName: "A500 Kickstart 1.3",
            theory: [],
            analogy: "A register is an explicit variable.",
            keyIdea: "The destination is on the right.",
            starterCode: "    MOVEQ #42,D0\n    RTS",
            quiz: AssemblyQuiz(
                question: "What does MOVE do?",
                options: ["Copy", "Jump"],
                answer: 0,
                feedback: "MOVE copies the source value."
            )
        )

        let loadState = AssemblyLessonLoader.load(lesson)

        XCTAssertEqual(loadState.codeText, lesson.starterCode)
        XCTAssertEqual(loadState.selectedTutorialID, "")
        XCTAssertEqual(
            loadState.emulatorPresetID,
            "a500-kickstart-13",
            "Loading a lesson must carry its emulator profile into the editor state."
        )
    }

    func testDockerBackendDisplayNameAndArgs() {
        XCTAssertEqual(EmulatorBackend.docker.displayName, "Docker (vamos)")
        let service = EmulatorService.shared
        let vasmArgs = service.buildDockerVasmArguments(
            workDir: "/tmp/work",
            sourceFileName: "program.s",
            outputFileName: "program"
        )
        XCTAssertEqual(vasmArgs[0], "run")
        XCTAssertTrue(vasmArgs.contains("sebastianbergmann/m68k-amigaos-bebbo"))
        XCTAssertTrue(vasmArgs.contains("/opt/folder/program.s"))

        let vamosArgs = service.buildDockerVamosArguments(
            workDir: "/tmp/work",
            binaryFileName: "program",
            cpu: "68020"
        )
        XCTAssertTrue(vamosArgs.contains("sebastianbergmann/amitools:latest"))
        XCTAssertTrue(vamosArgs.contains("vamos"))
        XCTAssertTrue(vamosArgs.contains("68020"))
    }

    func testLoadLastEditedFilePreferenceDefaultsOff() {
        XCTAssertEqual(AppPreferenceDefaults.loadLastEditedFileKey, "loadLastEditedFile")
        XCTAssertFalse(AppPreferenceDefaults.loadLastEditedFile)
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
