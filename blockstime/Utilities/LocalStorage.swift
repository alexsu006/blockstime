//
//  LocalStorage.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

class LocalStorage {
    static let shared = LocalStorage()

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: Constants.appGroupId)
    }

    private init() {}

    func saveCategories(_ categories: [Category]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(categories)

            // Save to shared UserDefaults for widget access
            sharedDefaults?.set(data, forKey: Constants.storageKey)

            // Force synchronize to ensure data is written immediately
            sharedDefaults?.synchronize()

            // Refresh widgets after saving data - ensure it runs on main thread
            #if canImport(WidgetKit)
            if #available(iOS 14.0, macOS 11.0, *) {
                DispatchQueue.main.async {
                    WidgetCenter.shared.reloadAllTimelines()
                    print("Widget timelines reloaded")
                }
            }
            #endif
        } catch {
            print("Failed to save categories: \(error)")
        }
    }

    func loadCategories() -> [Category] {
        guard let data = sharedDefaults?.data(forKey: Constants.storageKey) else {
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
