//
//  RegisterCoordinator.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit

protocol RegisterCoordinatorDelegate: AnyObject {
    func goBack()
    func routeToMainScreen()
}

class RegisterCoordinator: Coordinator {
    
    private weak var rootNavigationController: UINavigationController?
    private var childCoordinators = [Coordinator]()
    var onEnd: (() -> ())!
    
    init(rootNavigationController: UINavigationController) {
        self.rootNavigationController = rootNavigationController
    }
    
    func start() {
        guard let rootNavigationController = rootNavigationController else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: "Register") as? RegisterViewController else { return }
        let viewModel = RegisterViewModel()
        view.viewModel = viewModel
        viewModel.view = view
        viewModel.coordinator = self
        
        rootNavigationController.pushViewController(view, animated: true)
    }
    
    func add(childCoordinator: Coordinator) {
        childCoordinators.append(childCoordinator)
    }
    
    func remove(childCoordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: {$0 === childCoordinator}) else { return }
        childCoordinators.remove(at: index)
    }
    
    
}

extension RegisterCoordinator: RegisterCoordinatorDelegate {
    
    func goBack() {
        onEnd()
        rootNavigationController?.popViewController(animated: true)
    }
    
    func routeToMainScreen() {
        guard let rootNavigationController = rootNavigationController else { return }
        onEnd()
        let mapCoordinator = MapCoordinator(rootNavigationController: rootNavigationController)
        mapCoordinator.start()
    }
}
