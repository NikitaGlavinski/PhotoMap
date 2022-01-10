//
//  CategoryViewModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/9/21.
//

import Foundation

protocol CategorySelectionDelegate: AnyObject {
    func updateSelectedCategories(categories: [CategoryModel])
}

protocol CategoryViewModelProtocol: AnyObject {
    func viewDidLoad()
    func saveCategories(categories: [CategoryModel])
}

class CategoryViewModel {
    weak var view: CategoryViewInput!
    var coordinator: CategoryCoordinatorDelegate!
    var delegate: CategorySelectionDelegate!
    var categories: [CategoryModel]!
}

extension CategoryViewModel: CategoryViewModelProtocol {
    
    func viewDidLoad() {
        view.setCategories(categories: categories)
    }
    
    func saveCategories(categories: [CategoryModel]) {
        delegate.updateSelectedCategories(categories: categories)
        coordinator.goBack()
    }
}
