import Foundation

struct PickPlaceRecipe: Sendable, Equatable {
    var bowlX: Double
    var bowlY: Double
    var bowlZ: Double
    var targetX: Double
    var targetY: Double
    var safeZ: Double
    var pickZ: Double
    var placeZ: Double
    var feedMmPerMin: Double

    func run(on arm: HuenitArm) async throws {
        try await arm.moveAbsolute(x: bowlX, y: bowlY, z: safeZ, feedMmPerMin: feedMmPerMin)
        try await arm.moveAbsolute(x: bowlX, y: bowlY, z: pickZ, feedMmPerMin: feedMmPerMin)
        try await arm.setVacuum(true)
        try await arm.moveAbsolute(x: bowlX, y: bowlY, z: safeZ, feedMmPerMin: feedMmPerMin)
        try await arm.moveAbsolute(x: targetX, y: targetY, z: safeZ, feedMmPerMin: feedMmPerMin)
        try await arm.moveAbsolute(x: targetX, y: targetY, z: placeZ, feedMmPerMin: feedMmPerMin)
        try await arm.setVacuum(false)
        try await arm.moveAbsolute(x: targetX, y: targetY, z: safeZ, feedMmPerMin: feedMmPerMin)
    }
}
