import Foundation
import Testing
@testable import AuDeluxe

struct AIPlaylistCriteriaTests {
    @Test("Criteria decode from a fenced local-model response")
    func criteriaDecodeFromFencedResponse() throws {
        // Given
        let response = """
        ```json
        {"name":"Jazz break","folderTerms":["Jazz"],"fileTypes":["mod"],"minimumRating":3,"limit":12}
        ```
        """

        // When
        let criteria = try AIPlaylistCriteria.decodeModelResponse(response)

        // Then
        #expect(criteria.name == "Jazz break")
        #expect(criteria.folderTerms == ["Jazz"])
        #expect(criteria.fileTypes == ["MOD"])
        #expect(criteria.minimumRating == 3)
        #expect(criteria.limit == 12)
    }

    @Test("Missing optional criteria use safe defaults")
    func missingCriteriaUseDefaults() throws {
        // Given
        let response = "{\"name\":\"Everything\"}"

        // When
        let criteria = try AIPlaylistCriteria.decodeModelResponse(response)

        // Then
        #expect(criteria.titleTerms.isEmpty)
        #expect(criteria.artistTerms.isEmpty)
        #expect(criteria.folderTerms.isEmpty)
        #expect(criteria.fileTypes.isEmpty)
        #expect(criteria.limit == 25)
    }
}
