import Foundation

struct WindowSize: Sendable {
    let width: CGFloat
    let height: CGFloat

    static let standard = WindowSize(
        width: DesignTokens.Layout.defaultWindowWidth,
        height: DesignTokens.Layout.defaultWindowHeight
    )

    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }

    init(values: [String: String]) throws {
        let widthValue = values["-qa-window-width"]
        let heightValue = values["-qa-window-height"]
        guard widthValue != nil || heightValue != nil else {
            self = .standard
            return
        }
        guard let widthValue,
              let heightValue,
              let width = Double(widthValue),
              let height = Double(heightValue),
              width >= DesignTokens.Layout.minimumWindowWidth,
              height >= DesignTokens.Layout.minimumWindowHeight else {
            throw LaunchArgumentError.invalidWindowSize
        }
        self.init(width: width, height: height)
    }
}
