import Foundation

struct ImageBatchProgress: Sendable {
    let currentInputURL: URL
    let completedCount: Int
    let totalCount: Int
}

struct ImageBatchSuccess: Sendable {
    let inputURL: URL
    let outputURL: URL
}

struct ImageBatchFailure: Sendable {
    let inputURL: URL
    let message: String
}

struct ImageBatchResult: Sendable {
    let successes: [ImageBatchSuccess]
    let failures: [ImageBatchFailure]
    let wasCancelled: Bool
}

protocol ImageConverting {
    func convert(url: URL, nPlanes: Int, outputURL: URL) async throws
}

extension ImageConverter: ImageConverting {}

actor BatchImageConverter {
    typealias ProgressHandler = @MainActor @Sendable (ImageBatchProgress) -> Void

    private let imageConverter: any ImageConverting
    private let fileManager: FileManager

    init(
        imageConverter: any ImageConverting = ImageConverter(),
        fileManager: FileManager = .default
    ) {
        self.imageConverter = imageConverter
        self.fileManager = fileManager
    }

    func convert(
        inputURLs: [URL],
        outputDirectory: URL,
        nPlanes: Int,
        progress: @escaping ProgressHandler
    ) async -> ImageBatchResult {
        var successes = [ImageBatchSuccess]()
        var failures = [ImageBatchFailure]()
        var reservedOutputURLs = Set<URL>()

        do {
            try fileManager.createDirectory(
                at: outputDirectory,
                withIntermediateDirectories: true
            )
        } catch {
            let message = error.localizedDescription
            failures = inputURLs.map { ImageBatchFailure(inputURL: $0, message: message) }
            return ImageBatchResult(
                successes: [],
                failures: failures,
                wasCancelled: false
            )
        }

        for inputURL in inputURLs {
            guard !Task.isCancelled else {
                return ImageBatchResult(
                    successes: successes,
                    failures: failures,
                    wasCancelled: true
                )
            }

            let outputURL = availableOutputURL(
                for: inputURL,
                in: outputDirectory,
                reservedOutputURLs: reservedOutputURLs
            )
            reservedOutputURLs.insert(outputURL)

            await progress(
                ImageBatchProgress(
                    currentInputURL: inputURL,
                    completedCount: successes.count + failures.count,
                    totalCount: inputURLs.count
                )
            )

            do {
                try await imageConverter.convert(
                    url: inputURL,
                    nPlanes: nPlanes,
                    outputURL: outputURL
                )
                successes.append(
                    ImageBatchSuccess(inputURL: inputURL, outputURL: outputURL)
                )
            } catch is CancellationError {
                return ImageBatchResult(
                    successes: successes,
                    failures: failures,
                    wasCancelled: true
                )
            } catch {
                failures.append(
                    ImageBatchFailure(
                        inputURL: inputURL,
                        message: error.localizedDescription
                    )
                )
            }

            await progress(
                ImageBatchProgress(
                    currentInputURL: inputURL,
                    completedCount: successes.count + failures.count,
                    totalCount: inputURLs.count
                )
            )
        }

        return ImageBatchResult(
            successes: successes,
            failures: failures,
            wasCancelled: false
        )
    }

    private func availableOutputURL(
        for inputURL: URL,
        in outputDirectory: URL,
        reservedOutputURLs: Set<URL>
    ) -> URL {
        let baseName = inputURL.deletingPathExtension().lastPathComponent
        var suffix = 1

        while true {
            let outputName = suffix == 1 ? baseName : "\(baseName)-\(suffix)"
            let candidate = outputDirectory
                .appendingPathComponent(outputName)
                .appendingPathExtension("iff")

            if !fileManager.fileExists(atPath: candidate.path),
               !reservedOutputURLs.contains(candidate) {
                return candidate
            }
            suffix += 1
        }
    }
}
