//
//  DeepLinkService.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/13/21.
//

import UIKit

protocol DeepLinkServiceProtocol: AnyObject {
    func openPhotoWith(navigationController: UINavigationController)
    func openPhotoFromAuth(navigationController: UINavigationController)
}

class DeepLinkService: DeepLinkServiceProtocol {
    
    static let shared: DeepLinkServiceProtocol = DeepLinkService()
    private init() {}
    
    static var path: String? = nil
    
    func openPhotoWith(navigationController: UINavigationController) {
        if let _ = SecureStorageService.shared.obtainToken() {
            let coordinator = MapCoordinator(rootNavigationController: navigationController)
            coordinator.start()
            
            FirebaseService.shared.getUserPhotos { result in
                switch result {
                case .success(let photos):
                    guard let index = photos.firstIndex(where: {URL(string: $0.imageUrl)?.path == DeepLinkService.path}) else { return }
                    let photoCardModel = PhotoCardModel(restModel: photos[index])
                    coordinator.showPhoto(with: photoCardModel)
                    DeepLinkService.path = nil
                case .failure:
                    DeepLinkService.path = nil
                    return
                }
            }
        } else {
            let coordinator = AuthCoordinator(rootNavigationController: navigationController)
            coordinator.start()
        }
    }
    
    func openPhotoFromAuth(navigationController: UINavigationController) {
        let mapCoordinator = MapCoordinator(rootNavigationController: navigationController)
        mapCoordinator.start()
        
        FirebaseService.shared.getUserPhotos { result in
            switch result {
            case .success(let photos):
                guard let index = photos.firstIndex(where: {URL(string: $0.imageUrl)?.path == DeepLinkService.path}) else { return }
                let photoCardModel = PhotoCardModel(restModel: photos[index])
                mapCoordinator.showPhoto(with: photoCardModel)
                DeepLinkService.path = nil
            case .failure:
                DeepLinkService.path = nil
                return
            }
        }
    }
}
