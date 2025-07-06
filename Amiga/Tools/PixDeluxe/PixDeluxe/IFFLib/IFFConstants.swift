//
//  IFFConstants.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import Foundation

// MARK: - IFF Chunk Identifiers

/// Standard IFF chunk identifiers used throughout the application.
let ILBM_ID_ILBM: IFF_ID = (UInt32("I".unicodeScalars.first!.value) << 24 | UInt32("L".unicodeScalars.first!.value) << 16 | UInt32("B".unicodeScalars.first!.value) << 8 | UInt32("M".unicodeScalars.first!.value))
let ILBM_ID_PBM:  IFF_ID = (UInt32("P".unicodeScalars.first!.value) << 24 | UInt32("B".unicodeScalars.first!.value) << 16 | UInt32("M".unicodeScalars.first!.value) << 8 | UInt32(" ".unicodeScalars.first!.value))
let ILBM_ID_BODY: IFF_ID = (UInt32("B".unicodeScalars.first!.value) << 24 | UInt32("O".unicodeScalars.first!.value) << 16 | UInt32("D".unicodeScalars.first!.value) << 8 | UInt32("Y".unicodeScalars.first!.value))


// MARK: - C Interoperability Constants

/// A boolean TRUE value for C interoperability.
let C_TRUE: IFF_Bool = 1
