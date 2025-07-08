//
//  IFFConstants.swift
//  PixDeluxe
//
//  Created by Mario Esposito on 7/6/25.
//

import Foundation

// AI_REVIEW: The C-defined macros for chunk IDs are not directly available in Swift.
// This file correctly re-defines them as Swift constants so they can be used
// in the parser, fixing the "Cannot find in scope" compiler errors.
let ILBM_ID_ILBM: IFF_ID = (UInt32("I".unicodeScalars.first!.value) << 24 | UInt32("L".unicodeScalars.first!.value) << 16 | UInt32("B".unicodeScalars.first!.value) << 8 | UInt32("M".unicodeScalars.first!.value))
let ILBM_ID_PBM:  IFF_ID = (UInt32("P".unicodeScalars.first!.value) << 24 | UInt32("B".unicodeScalars.first!.value) << 16 | UInt32("M".unicodeScalars.first!.value) << 8 | UInt32(" ".unicodeScalars.first!.value))
let ILBM_ID_BMHD: IFF_ID = (UInt32("B".unicodeScalars.first!.value) << 24 | UInt32("M".unicodeScalars.first!.value) << 16 | UInt32("H".unicodeScalars.first!.value) << 8 | UInt32("D".unicodeScalars.first!.value))
let ILBM_ID_BODY: IFF_ID = (UInt32("B".unicodeScalars.first!.value) << 24 | UInt32("O".unicodeScalars.first!.value) << 16 | UInt32("D".unicodeScalars.first!.value) << 8 | UInt32("Y".unicodeScalars.first!.value))
let ILBM_ID_CMAP: IFF_ID = (UInt32("C".unicodeScalars.first!.value) << 24 | UInt32("M".unicodeScalars.first!.value) << 16 | UInt32("A".unicodeScalars.first!.value) << 8 | UInt32("P".unicodeScalars.first!.value))
let ILBM_ID_CAMG: IFF_ID = (UInt32("C".unicodeScalars.first!.value) << 24 | UInt32("A".unicodeScalars.first!.value) << 16 | UInt32("M".unicodeScalars.first!.value) << 8 | UInt32("G".unicodeScalars.first!.value))


// MARK: - C Interoperability Constants

// A boolean TRUE value for C interoperability.
let C_TRUE: IFF_Bool = 1
