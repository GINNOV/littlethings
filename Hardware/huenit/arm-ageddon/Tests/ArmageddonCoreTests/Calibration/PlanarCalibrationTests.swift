import Testing
@testable import ArmageddonCore

struct PlanarCalibrationTests {
    @Test("eight point planar profile solves and validates held-out points")
    func eightPoints() throws {
        let points = [
            correspondence(0, 0, 10, 20),
            correspondence(1, 0, 30, 20),
            correspondence(1, 1, 30, 50),
            correspondence(0, 1, 10, 50),
            correspondence(0.25, 0.25, 15, 27.5, validation: true),
            correspondence(0.75, 0.75, 25, 42.5, validation: true)
        ]
        let profile = try PlanarCalibrationProfile(
            deviceID: "fixture-camera",
            format: CaptureFormat(width: 1280, height: 720, frameRate: 30),
            toolID: "tool-a",
            polygon: try CalibrationPolygon(vertices: [
                CalibrationPoint(x: 0, y: 0),
                CalibrationPoint(x: 40, y: 0),
                CalibrationPoint(x: 40, y: 60),
                CalibrationPoint(x: 0, y: 60)
            ]),
            safeZBand: try CalibrationSafeZBand(minimum: 0, maximum: 30),
            correspondences: points
        )
        #expect(profile.rmsErrorMillimeters < 0.001)
        #expect(profile.maximumValidationErrorMillimeters < 0.001)
        let transformed = try profile.transform(CalibrationPoint(x: 0.5, y: 0.5))
        #expect(abs(transformed.x - 20) < 0.001)
        #expect(abs(transformed.y - 35) < 0.001)
        #expect(profile.matches(deviceID: "fixture-camera", format: profile.format, toolID: "tool-a"))
        #expect(!profile.matches(deviceID: "other-camera", format: profile.format, toolID: "tool-a"))
    }

    @Test("calibration rejects collinear, invalid polygon, and high-error fixtures")
    func failures() throws {
        let format = CaptureFormat(width: 1280, height: 720, frameRate: 30)
        #expect(throws: CalibrationError.collinearFitPoints) {
            try PlanarCalibrationProfile(
                deviceID: "camera",
                format: format,
                toolID: "tool",
                polygon: try CalibrationPolygon(vertices: [
                    CalibrationPoint(x: 0, y: 0), CalibrationPoint(x: 1, y: 0), CalibrationPoint(x: 1, y: 1)
                ]),
                safeZBand: try CalibrationSafeZBand(minimum: 0, maximum: 1),
                correspondences: [
                    correspondence(0, 0, 0, 0), correspondence(1, 0, 1, 0),
                    correspondence(2, 0, 2, 0), correspondence(3, 0, 3, 0),
                    correspondence(0.5, 0.5, 0.5, 0.5, validation: true),
                    correspondence(0.6, 0.5, 0.6, 0.5, validation: true)
                ]
            )
        }
        #expect(throws: CalibrationError.invalidWorkspacePolygon) {
            try CalibrationPolygon(vertices: [
                CalibrationPoint(x: 0, y: 0), CalibrationPoint(x: 2, y: 2), CalibrationPoint(x: 0, y: 2), CalibrationPoint(x: 2, y: 0)
            ])
        }
    }

    private func correspondence(
        _ sourceX: Double,
        _ sourceY: Double,
        _ workspaceX: Double,
        _ workspaceY: Double,
        validation: Bool = false
    ) -> CalibrationCorrespondence {
        CalibrationCorrespondence(
            source: CalibrationPoint(x: sourceX, y: sourceY),
            workspace: CalibrationPoint(x: workspaceX, y: workspaceY),
            isValidation: validation
        )
    }
}
