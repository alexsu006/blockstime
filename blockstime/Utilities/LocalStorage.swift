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

enum StorageError: LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case noUserDefaults
    case dataCorrupted

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "無法保存資料: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "無法讀取資料: \(error.localizedDescription)"
        case .noUserDefaults:
            return "無法訪問儲存空間"
        case .dataCorrupted:
            return "資料已損壞"
        }
    }
}

class LocalStorage {
    static let shared = LocalStorage()

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: Constants.appGroupId)
    }

    // Published error state for UI feedback
    var lastError: StorageError?

    private init() {}

    func saveCategories(_ categories: [Category]) {
        lastError = nil

        print("💾 Saving \(categories.count) categories to shared storage...")

        guard sharedDefaults != nil else {
            lastError = .noUserDefaults
            print("❌ Error: \(StorageError.noUserDefaults.errorDescription ?? "Unknown error")")
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // Better debugging
            let data = try encoder.encode(categories)

            // Save to shared UserDefaults for widget access
            sharedDefaults?.set(data, forKey: Constants.storageKey)

            // Force synchronize to ensure data is written immediately
            let success = sharedDefaults?.synchronize() ?? false
            if success {
                print("✅ Data synchronized to shared storage successfully")
            } else {
                print("⚠️ Warning: UserDefaults synchronize returned false")
            }

            // Refresh widgets after saving data - ensure it runs on main thread
            #if canImport(WidgetKit)
            if #available(iOS 14.0, macOS 11.0, *) {
                DispatchQueue.main.async {
                    print("🔄 Triggering widget reload...")
                    WidgetCenter.shared.reloadAllTimelines()
                    print("✅ Widget reload triggered - widgets should update immediately")
                }
            }
            #endif

            print("✅ Successfully saved \(categories.count) categories")

            // Print category details for debugging
            for category in categories where category.hours > 0 {
                print("   - \(category.name): \(category.hours)h (\(category.blocksCount) blocks)")
            }
        } catch {
            lastError = .encodingFailed(error)
            print("❌ Failed to save categories: \(error.localizedDescription)")
        }
    }

    func loadCategories() -> [Category] {
        lastError = nil

        guard sharedDefaults != nil else {
            lastError = .noUserDefaults
            print("⚠️ No UserDefaults available, using defaults")
            return defaultCategories()
        }

        guard let data = sharedDefaults?.data(forKey: Constants.storageKey) else {
            print("ℹ️ No saved data found, using default categories")
            return defaultCategories()
        }

        do {
            let decoder = JSONDecoder()
            let categories = try decoder.decode([Category].self, from: data)
            print("✅ Successfully loaded \(categories.count) categories")
            return categories
        } catch {
            lastError = .decodingFailed(error)
            print("❌ Failed to load categories: \(error.localizedDescription)")
            print("⚠️ Falling back to default categories")
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
