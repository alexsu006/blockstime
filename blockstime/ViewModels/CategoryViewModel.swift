//
//  CategoryViewModel.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-10-30.
//

import Foundation
import Combine

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []

    private let storage = LocalStorage.shared

    init() {
        loadCategories()
    }

    // MARK: - Data Management

    func loadCategories() {
        categories = storage.loadCategories()
    }

    func saveCategories() {
        storage.saveCategories(categories)
    }

    // MARK: - Category Operations

    func addCategory() {
        let newCategory = Category(
            name: "類別 \(categories.count + 1)",
            hours: 0,
            colorId: LegoColor.allColors[categories.count % LegoColor.allColors.count].id
        )
        categories.append(newCategory)
        saveCategories()
    }

    func removeCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        saveCategories()
    }

    func updateCategoryName(_ category: Category, newName: String) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index].name = newName.isEmpty ? "未命名" : newName
            saveCategories()
        }
    }

    func updateCategoryHours(_ category: Category, newHours: Double) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            let totalUsed = totalUsedHours()
            categories[index].updateHours(newHours, totalUsed: totalUsed)
            // Explicitly trigger objectWillChange to ensure UI updates
            objectWillChange.send()
            saveCategories()
        }
    }

    func updateCategoryColor(_ category: Category, colorId: String) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index].colorId = colorId
            saveCategories()
        }
    }

    func moveBlock(from fromCategory: Category, to toCategory: Category) {
        guard fromCategory.id != toCategory.id else { return }

        if let fromIndex = categories.firstIndex(where: { $0.id == fromCategory.id }),
           let toIndex = categories.firstIndex(where: { $0.id == toCategory.id }),
           categories[fromIndex].hours >= Constants.blockHours {

            categories[fromIndex].hours -= Constants.blockHours
            categories[toIndex].hours += Constants.blockHours

            // Round to avoid floating point errors
            categories[fromIndex].hours = round(categories[fromIndex].hours * 10) / 10
            categories[toIndex].hours = round(categories[toIndex].hours * 10) / 10

            saveCategories()
        }
    }

    // MARK: - Statistics

    func totalUsedHours() -> Double {
        categories.reduce(0) { $0 + $1.hours }
    }

    func remainingHours() -> Double {
        Constants.totalHours - totalUsedHours()
    }

    func visibleCategories() -> [Category] {
        categories.filter { $0.hours > 0 }
    }

    // 計算某個類別可用的最大時數（168小時 - 其他類別總時數）
    func maxAvailableHours(for category: Category) -> Double {
        let otherCategoriesTotal = categories
            .filter { $0.id != category.id }
            .reduce(0) { $0 + $1.hours }
        return Constants.totalHours - otherCategoriesTotal
    }
}
