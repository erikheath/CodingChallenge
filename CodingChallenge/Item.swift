//
//  Item.swift
//  CodingChallenge
//
//  Created by Erik Heath Thomas on 9/30/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
