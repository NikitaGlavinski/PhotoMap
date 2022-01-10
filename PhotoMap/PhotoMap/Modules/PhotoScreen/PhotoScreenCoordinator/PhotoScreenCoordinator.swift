//
//  PhotoScreenCoordinator.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/7/21.
//

import UIKit

protocol PhotoScreenCoordinatorDelegate: AnyObject {
    func goBack(animated: Bool)
}

class PhotoScreenCoordinator: Coordinator {
    
    private weak var rootNavigationController: UINavigationController?
    private var childCoordinators = [Coordinator]()
    private var photoModel: PhotoCardModel
    var onEnd: (() -> ())!
    
    init(rootNavigationController: UINavigationController, photoModel: PhotoCardModel) {
        self.rootNavigationController = rootNavigationController
        self.photoModel = photoModel
    }
    
    func start() {
        guard let rootNavigationController = rootNavigationController else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: "Photo") as? PhotoScreenViewController else { return }
        let viewModel = PhotoScreenViewModel(photoModel: photoModel)
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

extension PhotoScreenCoordinator: PhotoScreenCoordinatorDelegate {
    func goBack(animated: Bool) {
        onEnd()
        if !animated {
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .fade
            rootNavigationController?.view.layer.add(transition, forKey: nil)
        }
        rootNavigationController?.popViewController(animated: animated)
    }
}
