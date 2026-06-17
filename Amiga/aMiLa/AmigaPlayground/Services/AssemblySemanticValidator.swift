import Foundation

struct AssemblySemanticValidationResult: Equatable {
    let failures: [String]

    var passed: Bool {
        failures.isEmpty
    }

    var summary: String {
        failures.isEmpty ? "Passed" : failures.joined(separator: "; ")
    }
}

enum AssemblySemanticValidator {
    static func validate(source: String, prompt: String) -> AssemblySemanticValidationResult {
        var failures: [String] = []
        let strippedSource = stripComments(from: source)
        let lowerPrompt = prompt.lowercased()

        failures.append(contentsOf: validateGlobalRules(in: strippedSource))
        failures.append(contentsOf: validateExecutableStructure(in: strippedSource))
        failures.append(contentsOf: validateAmigaProgramModelRules(in: source))
        failures.append(contentsOf: validateUnstructuredPromptCompleteness(source: source, prompt: prompt))

        if lowerPrompt.contains("copper") {
            failures.append(contentsOf: validateCopperRules(in: strippedSource, prompt: lowerPrompt))
        }

        if lowerPrompt.contains("blitter") || lowerPrompt.contains("blit") {
            failures.append(contentsOf: validateBlitterRules(in: strippedSource, prompt: lowerPrompt))
        }

        if lowerPrompt.contains("bitplane") || lowerPrompt.contains("screen") {
            failures.append(contentsOf: validateBitplaneRules(in: strippedSource))
        }

        if lowerPrompt.contains("sprite") {
            failures.append(contentsOf: validateSpriteRules(in: strippedSource))
        }

        if lowerPrompt.contains("audio") || lowerPrompt.contains("sound") {
            failures.append(contentsOf: validateAudioRules(in: strippedSource))
        }

        if lowerPrompt.contains("cia") || lowerPrompt.contains("joystick") || lowerPrompt.contains("mouse") || lowerPrompt.contains("keyboard") || lowerPrompt.contains("input") {
            failures.append(contentsOf: validateInputRules(in: strippedSource))
        }

        if lowerPrompt.contains("interrupt") || lowerPrompt.contains("irq") {
            failures.append(contentsOf: validateInterruptRules(in: strippedSource))
        }

        return AssemblySemanticValidationResult(failures: orderedUnique(failures))
    }

    private static func validateAmigaProgramModelRules(in source: String) -> [String] {
        guard source.contains("; @amiga:region model begin") else { return [] }
        return AmigaProgramSourceVerifier.failures(in: source)
            .map { "model source invariant: \($0)" }
    }

    private static func validateUnstructuredPromptCompleteness(source: String, prompt: String) -> [String] {
        guard !source.contains("; @amiga:region model begin") else { return [] }
        var failures: [String] = []
        let lowerSource = source.lowercased()
        let lowerPrompt = prompt.lowercased()

        // 1. Quoted text check
        let quotePattern = #"(?:"|'|“|”|‘|’)([^"'“”‘’\n\r]+)(?:"|'|“|”|‘|’)"#
        if let regex = try? NSRegularExpression(pattern: quotePattern) {
            let range = NSRange(prompt.startIndex..<prompt.endIndex, in: prompt)
            let matches = regex.matches(in: prompt, range: range)
            for match in matches {
                if let matchRange = Range(match.range(at: 1), in: prompt) {
                    let quotedText = String(prompt[matchRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !lowerSource.contains(quotedText.lowercased()) {
                        let isScrolling = lowerPrompt.contains("scroll")
                        let failureMsg = isScrolling
                            ? "Generated source is missing requested scrolling text '\(quotedText)'"
                            : "Generated source is missing requested text '\(quotedText)'"
                        failures.append(failureMsg)
                    }
                }
            }
        }

        // 2. Hardware systems check
        if lowerPrompt.contains("blitter") || lowerPrompt.contains("blit") {
            let keywords = ["blitter", "blit", "$40", "$58", "$50", "$54", "$64", "$66"]
            if !keywords.contains(where: { lowerSource.contains($0) }) {
                failures.append("Generated source is missing requested hardware system 'blitter'")
            }
        }

        if lowerPrompt.contains("copper") {
            let keywords = ["copper", "cop", "$80", "$88", "$96"]
            if !keywords.contains(where: { lowerSource.contains($0) }) {
                failures.append("Generated source is missing requested hardware system 'copper'")
            }
        }

        if lowerPrompt.contains("sprite") {
            let keywords = ["sprite", "spr", "$120"]
            if !keywords.contains(where: { lowerSource.contains($0) }) {
                failures.append("Generated source is missing requested hardware system 'sprite'")
            }
        }

        if lowerPrompt.contains("audio") || lowerPrompt.contains("sound") {
            let keywords = ["audio", "sound", "paula", "aud", "$a0", "$a4", "$a6", "$a8"]
            if !keywords.contains(where: { lowerSource.contains($0) }) {
                failures.append("Generated source is missing requested hardware system 'audio'")
            }
        }

        if lowerPrompt.contains("cia") || lowerPrompt.contains("joystick") || lowerPrompt.contains("mouse") || lowerPrompt.contains("keyboard") || lowerPrompt.contains("input") {
            let keywords = ["cia", "joystick", "joy", "mouse", "keyboard", "input", "$bfe001", "$dff00a"]
            if !keywords.contains(where: { lowerSource.contains($0) }) {
                failures.append("Generated source is missing requested hardware system 'input'")
            }
        }

        if lowerPrompt.contains("interrupt") || lowerPrompt.contains("irq") {
            let keywords = ["interrupt", "irq", "intena", "intreq", "$9a", "$9c"]
            if !keywords.contains(where: { lowerSource.contains($0) }) {
                failures.append("Generated source is missing requested hardware system 'interrupt'")
            }
        }

        return failures
    }

    private static func validateGlobalRules(in source: String) -> [String] {
        var failures: [String] = []

        for register in matches(pattern: #"(?i)(?<!\$)\b[da]([8-9]|[1-9][0-9]+)\b"#, in: source) {
            failures.append("invalid register \(register.lowercased())")
        }

        for literal in matches(pattern: #"(?i)\b0x[0-9a-f]+\b"#, in: source) {
            failures.append("C-style hex literal \(literal.lowercased())")
        }

        for register in matches(pattern: #"(?i)(?<!\$)\bDFF[0-9A-F]{3}\b"#, in: source) {
            failures.append("bare custom-chip register \(register.uppercased())")
        }

        for color in matches(pattern: #"(?i)\b(BLUE|RED|GREEN|YELLOW|CYAN|MAGENTA|PURPLE|WHITE|BLACK)\b"#, in: source) {
            failures.append("undefined symbolic color \(color.uppercased())")
        }

        for pseudo in matches(pattern: #"(?i)\b(dec\.l|dec\.w|dec\.b|wait\.l|wait\.w|wait\.b|and\.t|bpush|out)\b"#, in: source) {
            failures.append("invalid pseudo instruction \(pseudo.lowercased())")
        }

        if contains(pattern: #"(?i)dc\.[bwl]\s+#"#, in: source) {
            failures.append("immediate marker # is invalid in dc data directives")
        }

        if contains(pattern: #"(?im)^\s*SECTION\s*$"#, in: source) {
            failures.append("split SECTION directive")
        }

        return failures
    }

    private static func validateExecutableStructure(in source: String) -> [String] {
        var failures: [String] = []

        if !contains(pattern: #"(?im)^\s*SECTION\s+\S+\s*,\s*CODE(?:\s*,\s*CHIP)?\b"#, in: source) {
            failures.append("missing SECTION Code,CODE")
        }

        if !contains(pattern: #"(?im)^\s*XDEF\s+_Start\b"#, in: source) {
            failures.append("missing XDEF _Start")
        }

        if !contains(pattern: #"(?im)^_Start:\s*$"#, in: source) {
            failures.append("missing _Start label")
        }

        return failures
    }

    private static func validateCopperRules(in source: String, prompt: String) -> [String] {
        var failures: [String] = []
        let lowerSource = source.lowercased()

        if !lowerSource.contains("section") || !lowerSource.contains("code") || !lowerSource.contains("chip") {
            failures.append("copper program must use SECTION Code,CODE,CHIP")
        }

        if !lowerSource.contains("copperlist") {
            failures.append("missing CopperList label")
        }

        if !contains(pattern: #"(?i)\$80\s*\(\s*a[0-7]\s*\)"#, in: source) {
            failures.append("missing COP1LC $80(a6) install")
        }

        if !contains(pattern: #"(?i)\$88\s*\(\s*a[0-7]\s*\)"#, in: source) {
            failures.append("missing COPJMP1 $88(a6) strobe")
        }

        if !contains(pattern: #"(?i)\$96\s*\(\s*a[0-7]\s*\)"#, in: source) {
            failures.append("missing DMACON $96(a6) enable")
        }

        if !contains(pattern: #"(?i)dc\.w\s+\$ffff\s*,\s*\$fffe"#, in: source) {
            failures.append("missing copper list terminator dc.w $ffff,$fffe")
        }

        if prompt.contains("bounc") || prompt.contains("animated") {
            if !contains(pattern: #"(?i)(waitvblank|\$06\s*\(\s*a[0-7]\s*\)|vhposr|vposr)"#, in: source) {
                failures.append("missing vertical blank wait")
            }

            if !contains(pattern: #"(?i)btst\s+#6\s*,\s*\$bfe001"#, in: source) {
                failures.append("missing left mouse exit")
            }

            let updatesCopperWords = contains(pattern: #"(?im)^\s*(move|add|sub|neg|clr)\.[bwl]\s+[^;\n]+,\s*[A-Za-z_][A-Za-z0-9_]*Wait\b"#, in: source)
            let waitLabels = matches(pattern: #"(?im)^[A-Za-z_][A-Za-z0-9_]*Wait:"#, in: source)
            if !updatesCopperWords && waitLabels.count < 2 {
                failures.append("missing animated copper wait words")
            }
        }

        return failures
    }

    private static func validateBlitterRules(in source: String, prompt: String) -> [String] {
        var failures: [String] = []
        let blitterWaitPattern = #"(?i)btst\s+#(?:6|14)\s*,\s*\$02\s*\(\s*a[0-7]\s*\)"#

        if !contains(pattern: blitterWaitPattern, in: source) {
            failures.append("missing blitter busy wait btst #6,$02(a6)")
        }

        if !contains(pattern: #"(?i)btst\s+#6\s*,\s*\$02\s*\(\s*a[0-7]\s*\)"#, in: source) {
            failures.append("non-canonical blitter wait; use btst #6,$02(a6)")
        }

        if matches(pattern: blitterWaitPattern, in: source).count < 2 {
            failures.append("missing blitter wait after BLTSIZE")
        }

        if !contains(pattern: #"(?i)\$40\s*\(\s*a[0-7]\s*\)"#, in: source) {
            failures.append("missing BLTCON0 $40(a6) setup")
        }

        if !contains(pattern: #"(?i)\$58\s*\(\s*a[0-7]\s*\)"#, in: source) {
            failures.append("missing BLTSIZE $58(a6) start")
        }

        if !contains(pattern: #"(?i)\$(50|54)\s*\(\s*a[0-7]\s*\)"#, in: source) {
            failures.append("missing blitter source or destination pointer setup")
        }

        if !contains(pattern: #"(?i)\$(64|66)\s*\(\s*a[0-7]\s*\)"#, in: source) {
            failures.append("missing blitter modulo setup")
        }

        if prompt.contains("bob") || prompt.contains("object") || prompt.contains("collision") || prompt.contains("bounds") {
            failures.append(contentsOf: validateBlitterBOBRules(in: source, prompt: prompt))
        }

        return failures
    }

    private static func validateBlitterBOBRules(in source: String, prompt: String) -> [String] {
        var failures: [String] = []

        if prompt.contains("bob") || prompt.contains("object") {
            for label in ["BOBX", "BOBY", "BOBDX", "BOBDY", "BOBMask", "BOBImage"] {
                if !contains(pattern: #"(?im)^\#(label)\s*:"#, in: source) {
                    failures.append("missing blitter BOB \(label) state")
                }
            }
        }

        if prompt.contains("bounds") {
            for value in ["#16", "#288", "#32", "#176"] {
                let escapedValue = NSRegularExpression.escapedPattern(for: value)
                if !contains(pattern: #"(?i)\bcmp\.w\s+\#(escapedValue)\s*,"#, in: source) {
                    failures.append("missing bounds clamp \(value)")
                }
            }
            if !contains(pattern: #"(?i)neg\.w\s+BOBDX"#, in: source) {
                failures.append("missing horizontal bounds bounce")
            }
            if !contains(pattern: #"(?i)neg\.w\s+BOBDY"#, in: source) {
                failures.append("missing vertical bounds bounce")
            }
        }

        if prompt.contains("collision") {
            for label in ["TargetLeft", "TargetTop", "TargetRight", "TargetBottom", "CollisionState"] {
                if !contains(pattern: #"(?im)^\#(label)\s*:"#, in: source) {
                    failures.append("missing collision \(label) state")
                }
            }
            if !contains(pattern: #"(?i)move\.w\s+(#\$[0-9a-f]{3,4}|CollisionColor\s*\(\s*pc\s*\))\s*,\s*\$182\s*\(\s*a[0-7]\s*\)"#, in: source) {
                failures.append("missing collision color evidence")
            }
            if !contains(pattern: #"(?i)move\.w\s+#1\s*,\s*CollisionState"#, in: source) {
                failures.append("missing collision state set")
            }
        }

        return failures
    }

    private static func validateBitplaneRules(in source: String) -> [String] {
        var failures: [String] = []

        if !contains(pattern: #"(?i)\$100\s*\(\s*a[0-7]\s*\)"#, in: source) {
            failures.append("missing BPLCON0 $100(a6) setup")
        }

        if !contains(pattern: #"(?i)\$(e0|e2)\s*\(\s*a[0-7]\s*\)"#, in: source) {
            failures.append("missing bitplane pointer setup")
        }

        if !contains(pattern: #"(?i)SECTION\s+\S+\s*,\s*DATA\s*,\s*CHIP|ds\.b"#, in: source) {
            failures.append("missing CHIP bitplane data")
        }

        return failures
    }

    private static func validateSpriteRules(in source: String) -> [String] {
        var failures: [String] = []

        if !contains(pattern: #"(?i)\$120\s*\(\s*a[0-7]\s*\)|spr0"#, in: source) {
            failures.append("missing sprite 0 pointer/setup")
        }

        if !contains(pattern: #"(?i)dc\.w\s+\$0000\s*,\s*\$0000"#, in: source) {
            failures.append("missing sprite data terminator")
        }

        return failures
    }

    private static func validateAudioRules(in source: String) -> [String] {
        var failures: [String] = []

        for (offset, name) in [("$a0", "AUD0LCH"), ("$a4", "AUD0LEN"), ("$a6", "AUD0PER"), ("$a8", "AUD0VOL")] {
            let escapedOffset = NSRegularExpression.escapedPattern(for: offset)
            if !contains(pattern: "(?i)\(escapedOffset)\\s*\\(\\s*a[0-7]\\s*\\)", in: source) {
                failures.append("missing \(name) setup")
            }
        }

        if !contains(pattern: #"(?i)\$96\s*\(\s*a[0-7]\s*\)"#, in: source) {
            failures.append("missing audio DMA enable through DMACON")
        }

        return failures
    }

    private static func validateInputRules(in source: String) -> [String] {
        if !contains(pattern: #"(?i)\$bfe001|\$dff00a|\$0a\s*\(\s*a[0-7]\s*\)|cia|joy"#, in: source) {
            return ["missing CIA/joystick/mouse hardware read"]
        }

        return []
    }

    private static func validateInterruptRules(in source: String) -> [String] {
        var failures: [String] = []

        if !contains(pattern: #"(?i)\$9a\s*\(\s*a[0-7]\s*\)"#, in: source) {
            failures.append("missing INTENA $9a(a6) setup")
        }

        if !contains(pattern: #"(?i)\$9c\s*\(\s*a[0-7]\s*\)"#, in: source) {
            failures.append("missing INTREQ $9c(a6) acknowledge")
        }

        return failures
    }

    private static func stripComments(from source: String) -> String {
        source
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line -> String in
                guard let commentStart = line.firstIndex(of: ";") else {
                    return String(line)
                }
                return String(line[..<commentStart])
            }
            .joined(separator: "\n")
    }

    private static func contains(pattern: String, in source: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        return regex.firstMatch(in: source, range: range) != nil
    }

    private static func matches(pattern: String, in source: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        return regex.matches(in: source, range: range).compactMap { match in
            guard let matchRange = Range(match.range(at: 0), in: source) else { return nil }
            return String(source[matchRange])
        }
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        var unique: [String] = []

        for value in values where !seen.contains(value) {
            seen.insert(value)
            unique.append(value)
        }

        return unique
    }
}

enum AssemblyRepairPromptBuilder {
    static func prompt(originalRequest: String, source: String, compilerOutput: String, semanticFailures: [String], attempt: Int) -> String {
        let trimmedCompilerOutput = compilerOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        let semanticSummary = semanticFailures.isEmpty
            ? "No semantic validator failures were reported."
            : semanticFailures.map { "- \($0)" }.joined(separator: "\n")
        let correctionHint = hint(for: semanticFailures, originalRequest: originalRequest)

        return """
        Attempt \(attempt): fix the current Amiga Motorola 68000 source so it passes the full reliability gate.

        Original user request:
        ```text
        \(originalRequest)
        ```

        Requirements:
        - Return one complete corrected source file in a single fenced code block tagged assembly.
        - Fix compiler errors and semantic validator failures.
        - Preserve the user's requested behavior and existing labels unless a change is required to pass the gate.
        - Use only real 68000/VASM syntax. No pseudo instructions, C-style hex, invalid registers, or undefined color symbols.
        - Use lea $dff000,a6 and custom register offsets such as $180(a6), $80(a6), $88(a6), and $96(a6).
        - Return ONLY the entire corrected code block. Do not include explanation outside the code block.

        VASM output:
        ```text
        \(trimmedCompilerOutput.isEmpty ? "No compiler output." : trimmedCompilerOutput)
        ```

        Semantic validator failures:
        ```text
        \(semanticSummary)
        ```

        Correction hint:
        ```text
        \(correctionHint)
        ```

        Current source:
        ```assembly
        \(source)
        ```
        """
    }

    private static func hint(for semanticFailures: [String], originalRequest: String) -> String {
        let haystack = (semanticFailures.joined(separator: " ") + " " + originalRequest).lowercased()

        if haystack.contains("blitter") || haystack.contains("blt") {
            return "Use the canonical DMACONR byte busy test btst #6,$02(a6), set BLTCON0 at $40(a6), configure blitter pointers/modulos, start with BLTSIZE at $58(a6), then wait again."
        }

        if haystack.contains("copper") {
            return "Install CopperList through COP1LC $80(a6), strobe COPJMP1 $88(a6), enable copper DMA through DMACON $96(a6), and terminate with dc.w $ffff,$fffe."
        }

        if haystack.contains("model source invariant") || haystack.contains("@amiga:dispatch") {
            return "For every embedded Amiga program control, preserve the @amiga:model marker, the @amiga:dispatch marker, a nearby bsr/jsr to the action label, the action routine label, and any modeled state symbols."
        }

        return "Return a complete VASM-compatible source file that preserves the original requested behavior."
    }
}
