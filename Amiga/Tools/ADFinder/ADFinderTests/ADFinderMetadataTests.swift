import Foundation
import Testing

struct ADFinderMetadataTests {
    @Test("HDF document declarations advertise the HDF extension")
    func hdfDeclarationsAdvertiseHDFExtension() throws {
        // Given
        let info = try #require(Bundle.main.infoDictionary)

        // When
        let exported = try #require(info["UTExportedTypeDeclarations"] as? [[String: Any]])
        let imported = try #require(info["UTImportedTypeDeclarations"] as? [[String: Any]])
        let hdfExtensions = (exported + imported)
            .filter { $0["UTTypeIdentifier"] as? String == "public.retro.hdf" }
            .compactMap { declaration in
                let tags = declaration["UTTypeTagSpecification"] as? [String: Any]
                return tags?["public.filename-extension"] as? [String]
            }

        // Then
        #expect(hdfExtensions == [["hdf"], ["hdf"]])
    }
}
