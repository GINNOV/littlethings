import Foundation
import Testing

@MainActor
struct ADFlibBridgeCompatibilityTests {
    @Test("Derived ADFlib headers, runtime, manifest, and Swift file bridge agree")
    func derivedBridgeReadsWrittenFile() throws {
        // Given
        let provenanceURL = try #require(Bundle.main.url(forResource: "adflib-provenance", withExtension: "json"))
        let payload = try JSONSerialization.jsonObject(with: Data(contentsOf: provenanceURL)) as? [String: Any]
        let identity = try #require(payload?["canonical_identity"] as? [String: Any])
        let manifestVersion = try #require(identity["version"] as? String)
        let service = ADFService()
        let imageURL = try #require(service.createNewBlankADF(volumeName: "BRIDGETEST", fsType: FS_TYPE_OFS_SWIFT, bootBlockType: .generic))
        let inputURL = FileManager.default.temporaryDirectory.appendingPathComponent("known-\(UUID().uuidString).txt")
        let expected = Data("known bridge payload\n".utf8)
        try expected.write(to: inputURL)
        defer {
            service.closeADF()
            try? FileManager.default.removeItem(at: imageURL)
            try? FileManager.default.removeItem(at: inputURL)
        }

        // When
        let writeError = service.addFile(from: inputURL)
        let entry = service.listCurrentDirectory().first { $0.name == inputURL.lastPathComponent }
        let actual = entry.flatMap(service.readFileContent)

        // Then
        #expect(writeError == nil)
        #expect(actual == expected)
        #expect(String(cString: adfGetVersionNumber()) == manifestVersion)
        #expect(String(cString: adf_compiled_version()) == manifestVersion)
    }
}
