//
//  CategoryCoordinator.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/9/21.
//

import UIKit

protocol CategoryCoordinatorDelegate: AnyObject {
    func goBack()
}

class CategoryCoordinator: Coordinator {
    
    private weak var rootNavigationController: UINavigationController?
    private var childCoordinators = [Coordinator]()
    
    var delegate: CategorySelectionDelegate!
    var categories: [CategoryModel]
    var onEnd: (() -> ())!
    
    init(rootNavigationController: UINavigationController, categories: [CategoryModel], delegate: CategorySelectionDelegate) {
        self.rootNavigationController = rootNavigationController
        self.categories = categories
        self.delegate = delegate
    }
    
    func start() {
        guard let rootNavigationController = rootNavigationController else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: "Category") as? CategoryViewController else { return }
        let viewModel = CategoryViewModel()
        view.viewModel = viewModel
        viewModel.view = view
        viewModel.coordinator = self
        viewModel.delegate = delegate
        viewModel.categories = categories
        
        view.modalPresentationStyle = .fullScreen
        rootNavigationController.present(view, animated: true, completion: nil)
    }
    
    func add(childCoordinator: Coordinator) {
        childCoordinators.append(childCoordinator)
    }
    
    func remove(childCoordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: {$0 === childCoordinator}) else { return }
        childCoordinators.remove(at: index)
    }
    
    
}

extension CategoryCoordinator: CategoryCoordinatorDelegate {
    
    func goBack() {
        onEnd()
        rootNavigationController?.viewControllers.last?.dismiss(animated: true, completion: nil)
    }
}
