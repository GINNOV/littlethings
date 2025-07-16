//
//  SortOrder.swift
//  AuDeluxe
//
//  Created by Mario Esposito on 7/16/25.
//

import Foundation

// Defining the sort options in a dedicated enum.
// CaseIterable allows us to easily list all options in the UI.
// Identifiable is used by the ForEach loop in the Picker.
enum SortOrder: String, CaseIterable, Identifiable {
    case name = "Name"
    case duration = "Duration"
    case rating = "Rating"
    
    var id: String { self.rawValue }
}
