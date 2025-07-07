//
//  FocusedDocument.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import SwiftUI

private struct FocusedDocumentKey: FocusedValueKey {
    typealias Value = Binding<PixDeluxeDocument>
}

extension FocusedValues {
    var document: Binding<PixDeluxeDocument>? {
        get { self[FocusedDocumentKey.self] }
        set { self[FocusedDocumentKey.self] = newValue }
    }
}
