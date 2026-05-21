import XCTest
@testable import AmigaPlayground

class AmigaPlaygroundTests: XCTestCase {

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

    func testBuildVAmigaArgumentsIncludesAdfScriptAndCustomArgs() {
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
            "/tmp/test.adf",
            "/tmp/session.retrosh",
            "-help",
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

    // MARK: - Ollama/LM Studio Service Tests

    func testOllamaServiceApiUrl() {
        let service = OllamaService.shared

        // Save existing state to restore it later
        let originalProvider = service.provider
        let originalCustomUrl = service.customUrl

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
    }
}
