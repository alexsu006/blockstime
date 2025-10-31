//
//  Category.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import Foundation

struct Category: Identifiable, Codable {
    let id: String
    var name: String
    var hours: Double
    var colorId: String

    var color: LegoColor {
        LegoColor.allColors.first { $0.id == colorId } ?? LegoColor.allColors[0]
    }

    var blocksCount: Int {
        Int(ceil(hours / Constants.blockHours))
    }

    var percentage: Double {
        (hours / Constants.totalHours) * 100
    }

    init(id: String = UUID().uuidString, name: String, hours: Double, colorId: String) {
        self.id = id
        self.name = name
        self.hours = hours
        self.colorId = colorId
    }

    mutating func updateHours(_ newHours: Double, totalUsed: Double) {
        let maxAvailable = Constants.totalHours - totalUsed + self.hours
        self.hours = min(max(0, newHours), maxAvailable)
    }
}
