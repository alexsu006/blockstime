//
//  LocalStorage.swift
//  BlocksTime
//
//  Created by Claude on 2025-10-30.
//

import Foundation

class LocalStorage {
    static let shared = LocalStorage()

    private init() {}

    func saveCategories(_ categories: [Category]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(categories)
            UserDefaults.standard.set(data, forKey: Constants.storageKey)
        } catch {
            print("Failed to save categories: \(error)")
        }
    }

    func loadCategories() -> [Category] {
        guard let data = UserDefaults.standard.data(forKey: Constants.storageKey) else {
            return defaultCategories()
        }

        do {
            let decoder = JSONDecoder()
            let categories = try decoder.decode([Category].self, from: data)
            return categories
        } catch {
            print("Failed to load categories: \(error)")
            return defaultCategories()
        }
    }

    private func defaultCategories() -> [Category] {
        return [
            Category(name: "睡眠", hours: 56, colorId: "red"),
            Category(name: "工作", hours: 40, colorId: "orange"),
            Category(name: "自由", hours: 72, colorId: "green")
        ]
    }
}
