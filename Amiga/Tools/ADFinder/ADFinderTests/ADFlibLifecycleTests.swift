import Foundation
import Testing

@MainActor
struct ADFlibLifecycleTests {
    @Test("Sequential intent-style services share one process-wide ADFlib lifetime")
    func sequentialServicesShareRuntime() throws {
        // Given
        let first = ADFService()

        // When
        let firstURL = try #require(first.createNewBlankADF(volumeName: "SEQONE", fsType: FS_TYPE_OFS_SWIFT, bootBlockType: .generic))
        first.closeADF()
        let second = ADFService()
        let secondURL = try #require(second.createNewBlankADF(volumeName: "SEQTWO", fsType: FS_TYPE_OFS_SWIFT, bootBlockType: .generic))
        second.closeADF()
        defer {
            try? FileManager.default.removeItem(at: firstURL)
            try? FileManager.default.removeItem(at: secondURL)
        }

        // Then
        #expect(first.isADFlibAvailable)
        #expect(second.isADFlibAvailable)
        #expect(adf_runtime_init_count() == 1)
        #expect(adf_runtime_dump_registration_count() == 1)
        #expect(adf_runtime_cleanup_count() == 0)
    }

    @Test("Overlapping intent-style services serialize through the main actor")
    func overlappingServicesShareRuntime() async {
        // Given
        let first = Task { @MainActor in
            let service = ADFService()
            let url = service.createNewBlankADF(volumeName: "OVERONE", fsType: FS_TYPE_OFS_SWIFT, bootBlockType: .generic)
            service.closeADF()
            return url
        }
        let second = Task { @MainActor in
            let service = ADFService()
            let url = service.createNewBlankADF(volumeName: "OVERTWO", fsType: FS_TYPE_OFS_SWIFT, bootBlockType: .generic)
            service.closeADF()
            return url
        }

        // When
        let urls = await [first.value, second.value]
        for url in urls.compactMap({ $0 }) {
            try? FileManager.default.removeItem(at: url)
        }

        // Then
        #expect(urls.allSatisfy { $0 != nil })
        #expect(adf_runtime_init_count() == 1)
        #expect(adf_runtime_dump_registration_count() == 1)
        #expect(adf_runtime_cleanup_count() == 0)
    }
}
