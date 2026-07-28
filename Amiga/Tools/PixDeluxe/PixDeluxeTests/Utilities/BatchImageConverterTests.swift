import Foundation
import Testing
@testable import PixDeluxe

struct BatchImageConverterTests {
    @Test("A PNG and JPEG batch produces two readable IFF files")
    func realImageBatchProducesReadableIFFs() async throws {
        let directory = try temporaryDirectory()
        let inputs = [
            try TestImageFactory.writeImage(
                named: "graphic",
                format: .png,
                to: directory
            ),
            try TestImageFactory.writeImage(
                named: "photo",
                format: .jpeg,
                to: directory
            )
        ]

        let result = await BatchImageConverter().convert(
            inputURLs: inputs,
            outputDirectory: directory.appendingPathComponent("Output"),
            nPlanes: 4,
            progress: { _ in }
        )

        #expect(result.successes.count == 2)
        #expect(result.failures.isEmpty)
        for success in result.successes {
            let data = try Data(contentsOf: success.outputURL)
            let parsed = try #require(
                IFFWrapper().parse(data: data, fileURL: success.outputURL)
            )
            #expect(parsed.cgImage.width == 16)
            #expect(parsed.cgImage.height == 8)
            #expect(parsed.details.depth == 4)
        }
    }

    @Test("Multiple inputs are converted into the selected directory")
    func multipleInputsAreConverted() async throws {
        let directory = try temporaryDirectory()
        let inputs = [
            directory.appendingPathComponent("one.png"),
            directory.appendingPathComponent("two.jpg")
        ]
        let converter = RecordingConverter()
        let outputDirectory = directory.appendingPathComponent("Output")

        let result = await BatchImageConverter(imageConverter: converter).convert(
            inputURLs: inputs,
            outputDirectory: outputDirectory,
            nPlanes: 5,
            progress: { _ in }
        )

        #expect(result.successes.map(\.inputURL) == inputs)
        #expect(result.failures.isEmpty)
        #expect(await converter.receivedPlaneCounts() == [5, 5])
    }

    @Test("Duplicate names use deterministic non-overwriting output names")
    func duplicateNamesAreRenamed() async throws {
        let directory = try temporaryDirectory()
        let firstDirectory = directory.appendingPathComponent("First")
        let secondDirectory = directory.appendingPathComponent("Second")
        try FileManager.default.createDirectory(at: firstDirectory, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: secondDirectory, withIntermediateDirectories: true)
        let inputs = [
            firstDirectory.appendingPathComponent("image.png"),
            secondDirectory.appendingPathComponent("image.jpg")
        ]
        let outputDirectory = directory.appendingPathComponent("Output")
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        try Data("existing".utf8).write(to: outputDirectory.appendingPathComponent("image.iff"))

        let result = await BatchImageConverter(imageConverter: RecordingConverter()).convert(
            inputURLs: inputs,
            outputDirectory: outputDirectory,
            nPlanes: 4,
            progress: { _ in }
        )

        #expect(result.successes.map(\.outputURL.lastPathComponent) == [
            "image-2.iff",
            "image-3.iff"
        ])
        #expect(
            try Data(contentsOf: outputDirectory.appendingPathComponent("image.iff"))
                == Data("existing".utf8)
        )
    }

    @Test("A failed input does not prevent later conversions")
    func partialFailureContinuesBatch() async throws {
        let directory = try temporaryDirectory()
        let inputs = [
            directory.appendingPathComponent("good-1.png"),
            directory.appendingPathComponent("bad.png"),
            directory.appendingPathComponent("good-2.jpg")
        ]
        let converter = RecordingConverter(failingNames: ["bad.png"])

        let result = await BatchImageConverter(imageConverter: converter).convert(
            inputURLs: inputs,
            outputDirectory: directory.appendingPathComponent("Output"),
            nPlanes: 3,
            progress: { _ in }
        )

        #expect(result.successes.map(\.inputURL.lastPathComponent) == [
            "good-1.png",
            "good-2.jpg"
        ])
        #expect(result.failures.map(\.inputURL.lastPathComponent) == ["bad.png"])
        #expect(await converter.receivedInputNames() == [
            "good-1.png",
            "bad.png",
            "good-2.jpg"
        ])
    }

    @Test("Cancellation prevents subsequent conversions")
    func cancellationPreventsSubsequentConversions() async throws {
        let directory = try temporaryDirectory()
        let inputs = [
            directory.appendingPathComponent("first.png"),
            directory.appendingPathComponent("second.png")
        ]
        let converter = ControlledConverter()
        let batch = BatchImageConverter(imageConverter: converter)

        let task = Task {
            await batch.convert(
                inputURLs: inputs,
                outputDirectory: directory.appendingPathComponent("Output"),
                nPlanes: 2,
                progress: { _ in }
            )
        }
        await converter.waitUntilConversionStarts()
        task.cancel()
        await converter.releaseConversion()
        let result = await task.value

        #expect(result.wasCancelled)
        #expect(await converter.receivedInputNames() == ["first.png"])
        #expect(result.successes.isEmpty)
    }

    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("PixDeluxeBatchTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true
        )
        return url
    }
}

private enum StubConversionError: LocalizedError {
    case requestedFailure

    var errorDescription: String? {
        "Requested conversion failure"
    }
}

private actor RecordingConverter: ImageConverting {
    private let failingNames: Set<String>
    private var inputs = [URL]()
    private var planeCounts = [Int]()

    init(failingNames: Set<String> = []) {
        self.failingNames = failingNames
    }

    func convert(url: URL, nPlanes: Int, outputURL: URL) async throws {
        inputs.append(url)
        planeCounts.append(nPlanes)
        if failingNames.contains(url.lastPathComponent) {
            throw StubConversionError.requestedFailure
        }
        try Data("converted".utf8).write(to: outputURL)
    }

    func receivedInputNames() -> [String] {
        inputs.map(\.lastPathComponent)
    }

    func receivedPlaneCounts() -> [Int] {
        planeCounts
    }
}

private actor ControlledConverter: ImageConverting {
    private var inputs = [URL]()
    private var conversionContinuation: CheckedContinuation<Void, Never>?
    private var startContinuation: CheckedContinuation<Void, Never>?

    func convert(url: URL, nPlanes: Int, outputURL: URL) async throws {
        inputs.append(url)
        startContinuation?.resume()
        startContinuation = nil
        await withCheckedContinuation { continuation in
            conversionContinuation = continuation
        }
        try Task.checkCancellation()
    }

    func waitUntilConversionStarts() async {
        if inputs.isEmpty == false {
            return
        }
        await withCheckedContinuation { continuation in
            startContinuation = continuation
        }
    }

    func releaseConversion() {
        conversionContinuation?.resume()
        conversionContinuation = nil
    }

    func receivedInputNames() -> [String] {
        inputs.map(\.lastPathComponent)
    }
}
