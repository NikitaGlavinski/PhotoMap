//
//  AuthCoordinator.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit

protocol AuthCoordinatorDelegate {
    func routeToRegister()
    func routeToMainScreen()
}

class AuthCoordinator: Coordinator {
    private weak var rootNavigationController: UINavigationController?
    private var childCoordinators = [Coordinator]()
    
    init(rootNavigationController: UINavigationController) {
        self.rootNavigationController = rootNavigationController
    }
    
    func start() {
        guard let rootNavigationController = rootNavigationController else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: "Auth") as? AuthViewController else { return }
        let viewModel = AuthViewModel()
        view.viewModel = viewModel
        viewModel.view = view
        viewModel.coordinator = self
        
        rootNavigationController.setViewControllers([view], animated: true)
    }
    
    func add(childCoordinator: Coordinator) {
        childCoordinators.append(childCoordinator)
    }
    
    func remove(childCoordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: {$0 === childCoordinator}) else { return }
        childCoordinators.remove(at: index)
    }
}

extension AuthCoordinator: AuthCoordinatorDelegate {
    func routeToRegister() {
        guard let rootNavigationController = rootNavigationController else { return }
        let registerCoordinator = RegisterCoordinator(rootNavigationController: rootNavigationController)
        registerCoordinator.onEnd = { [unowned registerCoordinator] in
            self.remove(childCoordinator: registerCoordinator)
        }
        registerCoordinator.start()
        add(childCoordinator: registerCoordinator)
    }
    
    func routeToMainScreen() {
        guard let rootNavigationController = rootNavigationController else { return }
        if let _ = DeepLinkService.path {
            DeepLinkService.shared.openPhotoFromAuth(navigationController: rootNavigationController)
        } else {
            let mapCoordinator = MapCoordinator(rootNavigationController: rootNavigationController)
            mapCoordinator.start()
        }
    }
}
