import Testing
@testable import AmigaROMExplorer

struct HardwareModelTests {
    @Test func everyCatalogModelHasPhotoAsset() {
        let expectedAssets: [String: String] = [
            "a1000": "hardware-a1000",
            "a500": "hardware-a500",
            "a500plus": "hardware-a500plus",
            "a600": "hardware-a600",
            "a600hd": "hardware-a600",
            "a1200": "hardware-a1200",
            "a2000": "hardware-a2000",
            "a3000": "hardware-a3000",
            "a4000": "hardware-a4000",
            "a4000t": "hardware-a4000t",
            "cdtv": "hardware-cdtv",
            "cd32": "hardware-cd32",
            "a570": "hardware-a570"
        ]

        for model in HardwareModel.catalog {
            #expect(model.imageAssetName == expectedAssets[model.id], "Unexpected asset for \(model.id)")
            #expect(model.hasPhoto == true, "\(model.id) should have a photo")
            #expect(model.symbolName.isEmpty == false)
        }
    }

    @Test func variantModelsShareParentAssets() {
        let a600 = HardwareModel.catalog.first { $0.id == "a600" }
        let a600hd = HardwareModel.catalog.first { $0.id == "a600hd" }

        #expect(a600?.imageAssetName == a600hd?.imageAssetName)
    }
}