//
//  NewHDFDialogConfig.swift
//  ADFinder
//
//  Created by Mario Esposito on 7/25/25.
//

import Foundation

struct NewHDFDialogConfig: Identifiable {
    let id = UUID()
    let action: (String, Int, UInt8) -> Void // volumeName, sizeInMB, fsType
}
