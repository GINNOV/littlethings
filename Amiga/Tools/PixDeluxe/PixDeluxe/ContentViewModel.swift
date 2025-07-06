//
//  ContentViewModel.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    @Published var image: Image?
    @Published var imageDetails: IFFImageDetails?
    @Published var showingAboutView = false
}
