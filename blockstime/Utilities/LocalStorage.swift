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
        print("   App Group ID: \(Constants.appGroupId)")
        print("   Storage Key: \(Constants.storageKey)")

        guard let defaults = sharedDefaults else {
            lastError = .noUserDefaults
            print("❌ Main App: Failed to access shared UserDefaults for app group '\(Constants.appGroupId)'")
            print("⚠️ Main App: This usually means:")
            print("   1. App Group is not enabled in Xcode project settings")
            print("   2. App Group is not configured in Apple Developer account")
            return
        }

        print("✅ Main App: Successfully accessed shared UserDefaults")

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // Better debugging
            let data = try encoder.encode(categories)

            print("📦 Main App: Encoded data size: \(data.count) bytes")

            // Save to shared UserDefaults for widget access
            defaults.set(data, forKey: Constants.storageKey)
            print("💾 Main App: Data saved to key '\(Constants.storageKey)'")

            // Force synchronize to ensure data is written immediately
            let success = defaults.synchronize()
            if success {
                print("✅ Main App: Data synchronized to shared storage successfully")
            } else {
                print("⚠️ Main App: UserDefaults synchronize returned false")
            }

            // Verify the data was saved
            if let verifyData = defaults.data(forKey: Constants.storageKey) {
                print("✅ Main App: Verified data exists (\(verifyData.count) bytes)")
            } else {
                print("❌ Main App: Failed to verify saved data!")
            }

            // List all keys in shared storage for debugging
            let allKeys = Array(defaults.dictionaryRepresentation().keys)
            print("📋 Main App: All keys in shared storage: \(allKeys.joined(separator: ", "))")

            // Refresh widgets after saving data - ensure it runs on main thread
            #if canImport(WidgetKit)
            if #available(iOS 14.0, macOS 11.0, *) {
                DispatchQueue.main.async {
                    print("🔄 Main App: Triggering widget reload...")
                    WidgetCenter.shared.reloadAllTimelines()
                    print("✅ Main App: Widget reload triggered - widgets should update immediately")
                }
            }
            #endif

            print("✅ Main App: Successfully saved \(categories.count) categories")

            // Print category details for debugging
            for category in categories where category.hours > 0 {
                print("   - \(category.name): \(category.hours)h (\(category.blocksCount) blocks)")
            }
        } catch {
            lastError = .encodingFailed(error)
            print("❌ Main App: Failed to save categories: \(error.localizedDescription)")
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
