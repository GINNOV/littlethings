import Foundation

enum ROMPathParser {
    static func parse(manifest: ManifestEntry) -> ParsedROMMetadata {
        let destination = manifest.destination
        let components = destination.split(separator: "/").map(String.init)
        let category = ROMCategory.from(path: destination)
        let fileName = components.last ?? destination
        let ext = (fileName as NSString).pathExtension.lowercased()

        let machinePath = extractMachinePath(components: components, category: category)
        let variantLabel = extractVariantLabel(components: components, category: category, fileName: fileName)
        let versionLabel = extractVersion(
            from: components,
            category: category,
            source: manifest.source,
            machinePath: machinePath
        )
        let hardwareTokens = extractHardwareTokens(machinePath: machinePath, source: manifest.source, fileName: fileName)
        let hardwareModels = HardwareModel.resolve(from: hardwareTokens)
        let publisher = extractPublisher(from: manifest.source, fileName: fileName)
        let year = extractYear(from: manifest.source, fileName: fileName)
        let dumpQuality = extractDumpQuality(variant: variantLabel, fileName: fileName, source: manifest.source)

        let title = buildTitle(
            source: manifest.source,
            category: category,
            version: versionLabel,
            machines: hardwareModels,
            year: year
        )
        let subtitle = buildSubtitle(
            machines: hardwareModels,
            publisher: publisher,
            year: year,
            variant: variantLabel,
            title: title
        )

        return ParsedROMMetadata(
            category: category,
            versionLabel: versionLabel,
            machinePath: machinePath,
            variantLabel: variantLabel,
            title: title,
            subtitle: subtitle,
            hardwareTokens: hardwareTokens,
            hardwareModels: hardwareModels,
            publisher: publisher,
            year: year,
            dumpQuality: dumpQuality,
            fileExtension: ext.isEmpty ? "rom" : ext
        )
    }

    private static func extractMachinePath(components: [String], category: ROMCategory) -> String {
        switch category {
        case .kickstart, .extendedROM:
            return components.count > 2 ? components[2] : "common"
        case .bootROM, .bootstrap:
            return components.count > 1 ? components[1] : "common"
        case .cartridges:
            return components.count > 1 ? components[1] : "unknown"
        case .other:
            return "other"
        }
    }

    private static func extractVariantLabel(components: [String], category: ROMCategory, fileName: String) -> String {
        let folderVariant: String? = switch category {
        case .kickstart, .extendedROM:
            components.count > 3 ? components[3] : "standard"
        case .bootROM:
            components.count > 3 ? components[3] : "standard"
        case .bootstrap:
            components.count > 2 ? components[2] : "standard"
        case .cartridges:
            components.count > 3 ? components[3] : "standard"
        case .other:
            "standard"
        }

        guard let folderVariant else { return "standard" }
        if folderVariant.lowercased().hasSuffix(".rom") || folderVariant.contains(".") {
            return "standard"
        }
        return folderVariant
    }

    private static func buildTitle(
        source: String,
        category: ROMCategory,
        version: String,
        machines: [HardwareModel],
        year: Int?
    ) -> String {
        if let cleaned = cleanSourceTitle(source) {
            return cleaned
        }

        var parts = [category.title]
        if !version.isEmpty, version != "unknown", !isMachineToken(version) {
            parts.append(formatToken(version))
        }
        if machines.count == 1 {
            parts.append(machines[0].name)
        } else if machines.count > 1 {
            parts.append(machines.map(\.name).joined(separator: " / "))
        } else if let year {
            parts.append(String(year))
        }
        return parts.joined(separator: " · ")
    }

    private static func buildSubtitle(
        machines: [HardwareModel],
        publisher: String?,
        year: Int?,
        variant: String,
        title: String
    ) -> String? {
        var parts: [String] = []

        if machines.count == 1, !title.localizedCaseInsensitiveContains(machines[0].name) {
            parts.append(machines[0].name)
        } else if machines.count > 1 {
            let names = machines.map(\.name).joined(separator: " · ")
            if !title.contains(names) {
                parts.append(names)
            }
        }

        if let publisher, !title.localizedCaseInsensitiveContains(publisher) {
            parts.append(publisher)
        }

        if let year, !title.contains(String(year)) {
            parts.append(String(year))
        }

        let variantLabel = humanizedVariant(variant)
        if let variantLabel, !title.localizedCaseInsensitiveContains(variantLabel) {
            parts.append(variantLabel)
        }

        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private static func cleanSourceTitle(_ source: String) -> String? {
        var name = source.trimmingCharacters(in: .whitespacesAndNewlines)
        if let dot = name.lastIndex(of: ".") {
            name = String(name[..<dot])
        }
        if let bracket = name.firstIndex(of: "[") {
            name = String(name[..<bracket]).trimmingCharacters(in: .whitespaces)
        }
        if let paren = name.firstIndex(of: "(") {
            let lead = String(name[..<paren]).trimmingCharacters(in: .whitespaces)
            if !lead.isEmpty {
                return lead
            }
        }
        return name.isEmpty ? nil : name
    }

    private static func humanizedVariant(_ variant: String) -> String? {
        let lowered = variant.lowercased()
        let ignored = ["standard", "common", "unknown", "other"]
        guard !ignored.contains(lowered) else { return nil }

        return variant
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    private static func formatToken(_ token: String) -> String {
        token
            .replacingOccurrences(of: "kickstart-", with: "")
            .replacingOccurrences(of: "-", with: ".")
            .replacingOccurrences(of: ".r", with: " r")
    }

    private static func isMachineToken(_ token: String) -> Bool {
        HardwareModel.catalog.contains { $0.id == token.lowercased() }
    }

    private static func extractVersion(
        from components: [String],
        category: ROMCategory,
        source: String,
        machinePath: String
    ) -> String {
        if category == .kickstart, let versionComponent = components.dropFirst().first {
            if versionComponent.hasPrefix("v") || versionComponent.hasPrefix("kickstart-") {
                return formatToken(versionComponent)
            }
        }

        if category == .bootROM, components.count > 2 {
            let candidate = components[2]
            if candidate.hasPrefix("v") || candidate.contains("r") {
                return formatToken(candidate)
            }
        }

        if let match = source.range(of: #"v\d[\d\.\-]*"#, options: .regularExpression) {
            return formatToken(String(source[match]))
        }

        if let revision = components.first(where: { $0.hasPrefix("r") && $0.count > 1 && $0 != machinePath }) {
            return revision
        }

        if category == .bootstrap || category == .bootROM {
            return ""
        }

        let fallback = components.dropFirst().first ?? ""
        return isMachineToken(fallback) ? "" : fallback
    }

    private static func extractHardwareTokens(machinePath: String, source: String, fileName: String) -> [String] {
        var tokens = machinePath
            .split(separator: "-")
            .map { String($0).lowercased() }
            .filter { !$0.isEmpty && $0 != "common" && $0 != "standard" && $0 != "unknown" }

        let haystack = "\(source) \(fileName)".lowercased()
        for model in HardwareModel.catalog {
            if haystack.contains(model.id) {
                tokens.append(model.id)
            }
        }

        return Array(Set(tokens)).sorted()
    }

    private static func extractPublisher(from source: String, fileName: String) -> String? {
        let pattern = #"\((\d{4}|19\d{2}|20\d{2})\)\(([^)]+)\)"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: source, range: NSRange(source.startIndex..., in: source)),
           let range = Range(match.range(at: 2), in: source) {
            return String(source[range])
        }

        let known = ["Commodore", "Datel Electronics", "GameWorks", "Data & Electronics", "Design & Engineering"]
        let combined = "\(source) \(fileName)"
        return known.first { combined.localizedCaseInsensitiveContains($0) }
    }

    private static func extractYear(from source: String, fileName: String) -> Int? {
        let haystack = "\(source) \(fileName)"
        let pattern = #"(19|20)\d{2}"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: haystack, range: NSRange(haystack.startIndex..., in: haystack)),
              let range = Range(match.range, in: haystack) else {
            return nil
        }
        return Int(haystack[range])
    }

    private static func extractDumpQuality(variant: String, fileName: String, source: String) -> ParsedROMMetadata.DumpQuality {
        let combined = "\(variant) \(fileName) \(source)".lowercased()
        if combined.contains("good") || combined.contains("[!]") { return .good }
        if combined.contains("beta") { return .beta }
        if combined.contains("developer") { return .developer }
        if combined.contains("hack") || combined.contains("-h-") || combined.contains("[h") { return .hack }
        if combined.contains("modified") || combined.contains("[m]") || combined.contains("-m.") { return .modified }
        if combined.contains("encrypted") { return .encrypted }
        if combined.contains("overdump") || combined.contains("-o-") { return .overdump }
        if combined.contains("bad-dump") || combined.contains("[b]") { return .badDump }
        if combined.contains("[u]") || variant == "unknown" { return .unknown }
        return .unknown
    }
}