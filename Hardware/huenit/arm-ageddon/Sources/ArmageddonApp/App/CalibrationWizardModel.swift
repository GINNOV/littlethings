import ArmageddonCore
import Foundation
import Observation

enum CalibrationWizardStep: Int, CaseIterable, Sendable {
    case hardware
    case mount
    case tool
    case points
    case review

    var title: String {
        switch self {
        case .hardware: "Camera"
        case .mount: "Mount"
        case .tool: "Tool"
        case .points: "Points"
        case .review: "Review"
        }
    }
}

enum CalibrationFixtureQuality: String, CaseIterable, Identifiable, Sendable {
    case valid
    case highError
    case duplicate
    case collinear
    case missingPose

    var id: String { rawValue }

    var title: String {
        switch self {
        case .valid: "Valid fixture"
        case .highError: "High-error fixture"
        case .duplicate: "Duplicate-point fixture"
        case .collinear: "Collinear fixture"
        case .missingPose: "Missing-pose fixture"
        }
    }
}

@MainActor
@Observable
final class CalibrationWizardModel {
    private let profileURL: URL?
    private(set) var step = CalibrationWizardStep.hardware
    private(set) var capturedPointCount = 0
    private(set) var candidateProfile: PlanarCalibrationProfile?
    private(set) var activeProfile: PlanarCalibrationProfile?
    private(set) var previousProfile: PlanarCalibrationProfile?
    private(set) var errorMessage: String?
    private(set) var resultMessage: String?
    private(set) var currentFormat = CaptureFormat(width: 1920, height: 1080, frameRate: 30)

    var selectedToolID = "standard-tool" {
        didSet { invalidateIfBindingChanged() }
    }
    var selectedCameraID = "fixture-camera" {
        didSet { invalidateIfBindingChanged() }
    }
    var fixtureQuality: CalibrationFixtureQuality = .valid {
        didSet {
            guard oldValue != fixtureQuality, candidateProfile != nil else { return }
            invalidateCandidate("Calibration input changed. Record the point sequence again.")
        }
    }

    init(profileURL: URL? = nil) {
        self.profileURL = profileURL
        if let profileURL,
           let data = try? Data(contentsOf: profileURL),
           let profile = try? JSONDecoder().decode(PlanarCalibrationProfile.self, from: data) {
            activeProfile = profile
        }
    }

    var canRecordPoint: Bool {
        step == .points && capturedPointCount < fixtureCorrespondences.count
    }

    var canSolve: Bool {
        step == .points && capturedPointCount == fixtureCorrespondences.count
    }

    var canActivate: Bool {
        candidateProfile != nil && errorMessage == nil
    }

    var calibrationStatus: String {
        if activeProfile != nil {
            return activeProfileIsCurrent ? "Active" : "Profile stale"
        }
        if candidateProfile != nil { return "Ready to review" }
        return "Not configured"
    }

    var residualSummary: String? {
        guard let candidateProfile else { return nil }
        return String(
            format: "RMS %.2f mm · maximum %.2f mm",
            candidateProfile.rmsErrorMillimeters,
            candidateProfile.maximumValidationErrorMillimeters
        )
    }

    func advance() {
        guard step != .review else { return }
        errorMessage = nil
        resultMessage = nil
        if step == .points {
            guard canSolve else { return }
            solve()
            return
        }
        step = CalibrationWizardStep(rawValue: step.rawValue + 1) ?? .review
    }

    func recordFixturePoint() {
        guard canRecordPoint else { return }
        capturedPointCount += 1
        errorMessage = nil
        resultMessage = nil
    }

    func updateCurrentFormat(_ format: CaptureFormat) {
        guard currentFormat != format else { return }
        currentFormat = format
        invalidateIfBindingChanged()
    }

    func solve() {
        guard canSolve else { return }
        guard fixtureQuality != .missingPose else {
            candidateProfile = nil
            errorMessage = "Activation disabled: no fresh arm pose is available. Reacquire pose, then record the points again."
            resultMessage = nil
            step = .review
            return
        }
        do {
            candidateProfile = try makeProfile()
            errorMessage = nil
            resultMessage = "Calibration solved. Review the residuals before activation."
            step = .review
        } catch let error as CalibrationError {
            candidateProfile = nil
            errorMessage = Self.message(for: error)
            resultMessage = nil
            step = .review
        } catch {
            candidateProfile = nil
            errorMessage = "Calibration could not be solved. Check the points and try again."
            resultMessage = nil
            step = .review
        }
    }

    func activate() {
        guard let candidateProfile, canActivate else { return }
        guard persist(candidateProfile) else {
            errorMessage = "Activation refused: the calibration profile could not be saved durably."
            return
        }
        previousProfile = activeProfile
        activeProfile = candidateProfile
        resultMessage = "Calibration is active for \(candidateProfile.toolID)."
    }

    func restorePrevious() {
        activeProfile = previousProfile
        previousProfile = nil
        if let activeProfile {
            _ = persist(activeProfile)
        } else if let profileURL {
            try? FileManager.default.removeItem(at: profileURL)
        }
        resultMessage = activeProfile == nil
            ? "The active calibration was removed."
            : "The previous calibration was restored."
    }

    func reset() {
        step = .hardware
        capturedPointCount = 0
        candidateProfile = nil
        errorMessage = nil
        resultMessage = nil
    }

    func installDeterministicFixtureProfile() {
        guard let profile = try? makeProfile() else { return }
        activeProfile = profile
        candidateProfile = nil
        errorMessage = nil
        resultMessage = "Deterministic calibration profile is active for supervised QA."
        step = .review
    }

    private var activeProfileIsCurrent: Bool {
        guard let activeProfile else { return false }
        return activeProfile.matches(
            deviceID: selectedCameraID,
            format: currentFormat,
            toolID: selectedToolID
        )
    }

    private func invalidateIfBindingChanged() {
        guard let candidateProfile else { return }
        if !candidateProfile.matches(
            deviceID: selectedCameraID,
            format: currentFormat,
            toolID: selectedToolID
        ) {
            invalidateCandidate("Activation disabled: the camera or tool changed after solving. Record the points again.")
        }
    }

    private func invalidateCandidate(_ message: String) {
        candidateProfile = nil
        errorMessage = message
        resultMessage = nil
    }

    private func persist(_ profile: PlanarCalibrationProfile) -> Bool {
        guard let profileURL else { return true }
        do {
            try FileManager.default.createDirectory(
                at: profileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true,
                attributes: [.posixPermissions: 0o700]
            )
            let data = try JSONEncoder.sorted.encode(profile)
            try data.write(to: profileURL, options: [.atomic, .completeFileProtection])
            return true
        } catch {
            return false
        }
    }

    private var fixtureCorrespondences: [CalibrationCorrespondence] {
        var source = [
            CalibrationPoint(x: 100, y: 100),
            CalibrationPoint(x: 1820, y: 100),
            CalibrationPoint(x: 1820, y: 980),
            CalibrationPoint(x: 100, y: 980),
            CalibrationPoint(x: 960, y: 540),
            CalibrationPoint(x: 100, y: 540),
            CalibrationPoint(x: 960, y: 100),
            CalibrationPoint(x: 960, y: 980),
        ]
        var workspace = [
            CalibrationPoint(x: 10, y: 10),
            CalibrationPoint(x: 190, y: 10),
            CalibrationPoint(x: 190, y: 140),
            CalibrationPoint(x: 10, y: 140),
            CalibrationPoint(x: 100, y: 75),
            CalibrationPoint(x: 10, y: 75),
            CalibrationPoint(x: 100, y: 10),
            CalibrationPoint(x: 100, y: 140),
        ]
        switch fixtureQuality {
        case .highError:
            workspace[6] = CalibrationPoint(x: 125, y: 10)
        case .duplicate:
            source[5] = source[0]
        case .collinear:
            for index in 0..<6 {
                source[index] = CalibrationPoint(x: 100, y: 100 + Double(index * 120))
            }
        case .valid, .missingPose:
            break
        }
        return zip(source, workspace).enumerated().map { index, pair in
            CalibrationCorrespondence(
                id: UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", index + 1)) ?? UUID(),
                source: pair.0,
                workspace: pair.1,
                isValidation: index >= 6
            )
        }
    }

    private func makeProfile() throws -> PlanarCalibrationProfile {
        let polygon = try CalibrationPolygon(vertices: [
            CalibrationPoint(x: 0, y: 0),
            CalibrationPoint(x: 200, y: 0),
            CalibrationPoint(x: 200, y: 150),
            CalibrationPoint(x: 0, y: 150),
        ])
        let safeZBand = try CalibrationSafeZBand(minimum: 20, maximum: 80)
        return try PlanarCalibrationProfile(
            deviceID: selectedCameraID,
            format: currentFormat,
            toolID: selectedToolID,
            polygon: polygon,
            safeZBand: safeZBand,
            correspondences: fixtureCorrespondences
        )
    }

    private static func message(for error: CalibrationError) -> String {
        switch error {
        case let .errorThresholdExceeded(rms, maximum):
            return String(format: "Activation disabled: RMS %.2f mm and maximum %.2f mm exceed the limits of 3.00 mm and 5.00 mm.", rms, maximum)
        case .notEnoughFitPoints: return "Record at least four fit points."
        case .notEnoughValidationPoints: return "Record at least two validation points."
        case .duplicatePoint: return "Two fit points are duplicates. Reposition and record again."
        case .collinearFitPoints: return "Fit points are collinear. Use points around the workspace."
        default: return "The calibration points are invalid. Reposition and try again."
        }
    }
}

private extension JSONEncoder {
    static var sorted: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
