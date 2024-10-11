//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Anton Demidenko on 11.10.24..
//

import Foundation


final class CategoryListViewModel {
    
    private let trackerCategoryStore = TrackerCategoryStore.shared
    
    var categories: [TrackerCategory] = []
    
    var selectedCategory: String?
    
    var onCategoriesUpdated: (() -> Void)?
    
    init() {
            trackerCategoryStore.onCategoriesUpdated = { [weak self] in
                self?.loadCategories()
            }
        }
    
    func loadCategories() {
        categories = trackerCategoryStore.fetchCategories()
        selectedCategory = trackerCategoryStore.loadSelectedCategory()?.title
        onCategoriesUpdated?()
    }
    
    func didSelectCategory(at indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row]
        if self.selectedCategory == selectedCategory.title {
            self.selectedCategory = nil
        } else {
            self.selectedCategory = selectedCategory.title
        }
    }
    
    func didAddCategory(_ category: String) {
        let newCategory = TrackerCategory(title: category, trackers: [])
        do {
            try trackerCategoryStore.addNewCategory(newCategory)
            loadCategories()
        } catch {
            print("Ошибка при добавлении категории: \(error)")
        }
    }
    
    func updateSelectedCategory(with title: String?) {
        trackerCategoryStore.updateSelectedCategory(with: title)
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        guard categories.indices.contains(indexPath.row) else {
            print("Индекс \(indexPath.row) выходит за пределы массива категорий")
            return
        }
        
        let categoryToDelete = categories[indexPath.row]
        
        do {
            try trackerCategoryStore.deleteCategory(withTitle: categoryToDelete.title)
            loadCategories()
        } catch {
            print("Ошибка при удалении категории: \(error)")
        }
    }
}
