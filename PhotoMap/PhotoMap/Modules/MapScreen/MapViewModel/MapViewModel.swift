//
//  MapViewModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit
import CoreLocation

protocol MapViewModelProtocol: AnyObject {
    func viewDidLoad()
    func takePhoto(touchCoordinate: CLLocationCoordinate2D)
    func choosePhoto(touchCoordinate: CLLocationCoordinate2D)
    func uploadImageData(from model: PhotoCardModel)
    func updatePhotoModel(model: PhotoCardModel)
    func loadImageFrom(url: String, completion: @escaping (UIImage) -> ())
    func showPhoto(with model: PhotoCardModel)
    func showCategories(selectedCategories: [Category])
}

class MapViewModel: NSObject {
    weak var view: MapViewInput!
    var coordinator: MapCoordinatorDelegate!
    private var touchCoordinate: CLLocationCoordinate2D?
    
    private var queue = DispatchQueue(label: "MapViewModelQueue", qos: .background)
    
    private func configPhotoModels(models: [PhotoCardModel]) {
        
    }
}

extension MapViewModel: MapViewModelProtocol {
    
    func viewDidLoad() {
        FirebaseService.shared.getUserPhotos { result in
            switch result {
            case .success(let photos):
                let photoModels = photos.compactMap({PhotoCardModel(restModel: $0)})
                self.view.setupAnnotations(models: photoModels)
            case .failure(let error):
                self.view.showError(error: error)
            }
        }
    }
    
    func takePhoto(touchCoordinate: CLLocationCoordinate2D) {
        self.touchCoordinate = touchCoordinate
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.mediaTypes = ["public.image"]
            picker.allowsEditing = true
            view.presentPicker(picker: picker)
        }
    }
    
    func choosePhoto(touchCoordinate: CLLocationCoordinate2D) {
        self.touchCoordinate = touchCoordinate
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.image"]
            picker.allowsEditing = true
            view.presentPicker(picker: picker)
        }
    }
    
    func uploadImageData(from model: PhotoCardModel) {
        var photos = SecureStorageService.shared.obtainPhotoModels()
        photos.append(PhotoRestModel(cardModel: model, imageUrl: ""))
        SecureStorageService.shared.savePhotoModels(models: photos)
        
        queue.async {
            guard
                let imageData = model.image?.jpegData(compressionQuality: 1),
                let token = SecureStorageService.shared.obtainToken()
            else { return }
            FirebaseService.shared.uploadImage(data: imageData) { result in
                switch result {
                case .success(let url):
                    let restModel = PhotoRestModel(cardModel: model, imageUrl: url)
                    FirebaseService.shared.setDataAt(path: "\(token)/\(restModel.id)", data: restModel) { result in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                self.view.addPin(model: model)
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                self.view.showError(error: error)
                            }
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.view.showError(error: error)
                    }
                }
            }
        }
    }
    
    func updatePhotoModel(model: PhotoCardModel) {
        guard
            let imageUrl = model.imageUrl,
            let token = SecureStorageService.shared.obtainToken()
        else { return }
        
        let restModel = PhotoRestModel(cardModel: model, imageUrl: imageUrl)
        FirebaseService.shared.setDataAt(path: "\(token)/\(restModel.id)", data: restModel) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.view.addPin(model: model)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view.showError(error: error)
                }
            }
        }
    }
    
    func loadImageFrom(url: String, completion: @escaping (UIImage) -> ()) {
        NetworkService.shared.loadImageFrom(url: url, completion: completion) { error in
            self.view.showError(error: error)
        }
    }
    
    func showPhoto(with model: PhotoCardModel) {
        coordinator.showPhoto(with: model)
    }
    
    func showCategories(selectedCategories: [Category]) {
        var categories = [
            CategoryModel(title: "FRIENDS", isSelected: false),
            CategoryModel(title: "NATURE", isSelected: false),
            CategoryModel(title: "DEFAULT", isSelected: false)
        ]
        for category in selectedCategories {
            guard let index = categories.firstIndex(where: {$0.title == category.rawValue}) else { return }
            categories[index].isSelected = true
        }
        coordinator.showCategories(categories: categories, delegate: self)
    }
}

extension MapViewModel: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        picker.dismiss(animated: false, completion: nil)
        
        guard let touchCoordinate = touchCoordinate else { return }
        let cardModel = PhotoCardModel(
            image: image,
            date: Date().timeIntervalSince1970,
            stringDate: "",
            category: .friends,
            text: "",
            lat: touchCoordinate.latitude,
            lon: touchCoordinate.longitude,
            email: SecureStorageService.shared.obtainEmail() ?? ""
        )
        view.showPopupView(with: cardModel)
    }
}

extension MapViewModel: CategorySelectionDelegate {
    
    func updateSelectedCategories(categories: [CategoryModel]) {
        var selectedCategories = [Category]()
        for category in categories {
            if category.isSelected {
                guard let selectedCategory = Category.init(rawValue: category.title) else { return }
                selectedCategories.append(selectedCategory)
            }
        }
        view.updateSelectedCategories(selectedCategories: selectedCategories)
    }
}
