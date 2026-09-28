public struct PickPlaceRecipe: Sendable, Equatable {
    public var bowlX: Double
    public var bowlY: Double
    public var targetX: Double
    public var targetY: Double
    public var safeZ: Double
    public var pickZ: Double
    public var placeZ: Double
    public var feedMmPerMin: Double

    public init(
        bowlX: Double,
        bowlY: Double,
        targetX: Double,
        targetY: Double,
        safeZ: Double,
        pickZ: Double,
        placeZ: Double,
        feedMmPerMin: Double
    ) {
        self.bowlX = bowlX
        self.bowlY = bowlY
        self.targetX = targetX
        self.targetY = targetY
        self.safeZ = safeZ
        self.pickZ = pickZ
        self.placeZ = placeZ
        self.feedMmPerMin = feedMmPerMin
    }

    public func run(on arm: HuenitArm) async throws {
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
