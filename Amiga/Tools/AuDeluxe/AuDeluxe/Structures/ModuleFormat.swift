import Foundation

enum ModuleFormat {
    static let supportedExtensions = [
        "mod", "s3m", "xm", "it", "med", "okt", "mtm", "669", "dsm", "far", "ptm", "ult",
        "amf", "ams", "dbm", "dmf", "imf", "j2b", "mdl", "mo3", "psm", "stm", "stx", "umx",
    ]

    private static let extensionSet = Set(supportedExtensions)

    static func isSupported(_ fileURL: URL) -> Bool {
        extensionSet.contains(fileURL.pathExtension.lowercased())
    }
}
