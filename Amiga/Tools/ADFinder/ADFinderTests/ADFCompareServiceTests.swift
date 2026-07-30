import Foundation
import Testing
@testable import ADFinder

struct ADFCompareServiceTests {
    @Test("Equal complete sectors are reported as identical")
    func equalSectorsAreIdentical() throws {
        // Given
        let service = ADFCompareService()
        service.sourceData = Data(repeating: 0x2A, count: 1_024)
        service.destinationData = Data(repeating: 0x2A, count: 1_024)

        // When
        service.compare()

        // Then
        let result = try #require(service.comparisonResult)
        #expect(result.sectorStates.map(\.description) == ["Identical", "Identical"])
        #expect(result.totalSectors == 2)
        #expect(result.differentSectors == 0)
    }

    @Test("Changed sectors are counted once")
    func changedSectorIsCountedOnce() throws {
        // Given
        let service = ADFCompareService()
        service.sourceData = Data(repeating: 0x00, count: 512)
        service.destinationData = Data(repeating: 0xFF, count: 512)

        // When
        service.compare()

        // Then
        let result = try #require(service.comparisonResult)
        #expect(result.sectorStates.map(\.description) == ["Different"])
        #expect(result.differentSectors == 1)
    }

    @Test("A trailing source sector is reported as source-only")
    func trailingSourceSectorIsSourceOnly() throws {
        // Given
        let service = ADFCompareService()
        service.sourceData = Data(repeating: 0x00, count: 1_024)
        service.destinationData = Data(repeating: 0x00, count: 512)

        // When
        service.compare()

        // Then
        let result = try #require(service.comparisonResult)
        #expect(result.sectorStates.map(\.description) == ["Identical", "Source Only"])
        #expect(result.sourceOnlySectors == 1)
    }

    @Test("A trailing destination sector is reported as destination-only")
    func trailingDestinationSectorIsDestinationOnly() throws {
        // Given
        let service = ADFCompareService()
        service.sourceData = Data(repeating: 0x00, count: 512)
        service.destinationData = Data(repeating: 0x00, count: 1_024)

        // When
        service.compare()

        // Then
        let result = try #require(service.comparisonResult)
        #expect(result.sectorStates.map(\.description) == ["Identical", "Destination Only"])
        #expect(result.destinationOnlySectors == 1)
    }

    @Test("Incomplete trailing bytes do not create a sector")
    func incompleteTrailingBytesAreIgnored() throws {
        // Given
        let service = ADFCompareService()
        service.sourceData = Data(repeating: 0x00, count: 511)
        service.destinationData = Data(repeating: 0x00, count: 511)

        // When
        service.compare()

        // Then
        let result = try #require(service.comparisonResult)
        #expect(result.sectorStates.isEmpty)
        #expect(result.totalSectors == 0)
    }
}
