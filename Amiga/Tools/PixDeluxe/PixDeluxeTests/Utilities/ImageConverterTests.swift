import Foundation
import Testing
@testable import PixDeluxe

struct ImageConverterTests {
    @Test("PNG conversion produces a readable IFF")
    func pngConversionProducesReadableIFF() async throws {
        let directory = try temporaryDirectory()
        let inputURL = try TestImageFactory.writeImage(
            named: "source",
            format: .png,
            to: directory
        )
        let outputURL = directory.appendingPathComponent("source.iff")

        try await ImageConverter().convert(
            url: inputURL,
            nPlanes: 2,
            outputURL: outputURL
        )

        let parseResult = try parseWithProductionReader(outputURL)
        let parsed = try #require(parseResult)
        #expect(parsed.cgImage.width == 16)
        #expect(parsed.cgImage.height == 8)
        #expect(parsed.details.depth == 2)
    }

    @Test("JPEG conversion produces a readable IFF")
    func jpegConversionProducesReadableIFF() async throws {
        let directory = try temporaryDirectory()
        let inputURL = try TestImageFactory.writeImage(
            named: "photo",
            format: .jpeg,
            to: directory
        )
        let outputURL = directory.appendingPathComponent("photo.iff")

        try await ImageConverter().convert(
            url: inputURL,
            nPlanes: 4,
            outputURL: outputURL
        )

        let parseResult = try parseWithProductionReader(outputURL)
        let parsed = try #require(parseResult)
        #expect(parsed.details.depth == 4)
        #expect(parsed.cgImage.width == 16)
        #expect(parsed.cgImage.height == 8)
    }

    @Test(
        "Supported bitplane boundaries are preserved in the IFF header",
        arguments: [1, 8]
    )
    func supportedBitplaneBoundaries(nPlanes: Int) async throws {
        let directory = try temporaryDirectory()
        let inputURL = try TestImageFactory.writeImage(
            named: "boundary-\(nPlanes)",
            format: .png,
            to: directory
        )
        let outputURL = directory.appendingPathComponent("boundary.iff")

        try await ImageConverter().convert(
            url: inputURL,
            nPlanes: nPlanes,
            outputURL: outputURL
        )

        let parseResult = try parseWithProductionReader(outputURL)
        let parsed = try #require(parseResult)
        #expect(parsed.details.depth == nPlanes)
    }

    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("PixDeluxeTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true
        )
        return url
    }

    private func parseWithProductionReader(_ url: URL) throws -> IFFWrapper.ParseResult? {
        try IFFWrapper().parse(
            data: Data(contentsOf: url),
            fileURL: url
        )
    }
}
