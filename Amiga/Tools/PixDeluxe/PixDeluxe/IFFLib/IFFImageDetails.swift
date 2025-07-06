//
//  IFFImageDetails.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import Foundation

struct IFFImageDetails {
    let fileName: String
    let width: Int
    let height: Int
    let depth: Int
    let colors: Int
    let compression: String
    let masking: String
    let aspectRatio: String
    let pageDimensions: String
    let viewportMode: String?
}
