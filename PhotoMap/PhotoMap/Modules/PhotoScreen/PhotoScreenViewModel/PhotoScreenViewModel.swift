//
//  PhotoScreenViewModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/7/21.
//

import Foundation
import UIKit

protocol PhotoScreenViewModelProtocol: AnyObject {
    func viewDidLoad()
    func goBack(animated: Bool)
    func loadImage(url: String, completion: @escaping (UIImage) -> ())
}

class PhotoScreenViewModel {
    weak var view: PhotoScreenViewInput!
    var coordinator: PhotoScreenCoordinatorDelegate!
    
    var photoModel: PhotoCardModel
    
    init(photoModel: PhotoCardModel) {
        self.photoModel = photoModel
    }
}

extension PhotoScreenViewModel: PhotoScreenViewModelProtocol {
    
    func viewDidLoad() {
        view.setupUI(with: photoModel)
    }
    
    func goBack(animated: Bool) {
        coordinator.goBack(animated: animated)
    }
    
    func loadImage(url: String, completion: @escaping (UIImage) -> ()) {
        NetworkService.shared.loadImageFrom(url: url, completion: completion) { error in
            self.view.showError(error: error)
        }
    }
}
