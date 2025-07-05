//
//  FocusedViewModel.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/5/25.
//

import SwiftUI

private struct FocusedViewModelKey: FocusedValueKey {
    typealias Value = ContentViewModel
}

extension FocusedValues {
    var viewModel: ContentViewModel? {
        get { self[FocusedViewModelKey.self] }
        set { self[FocusedViewModelKey.self] = newValue }
    }
}
