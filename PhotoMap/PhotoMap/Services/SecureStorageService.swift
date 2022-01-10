//
//  SecureStorageService.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import Foundation

protocol SecureStorageServiceProtocol {
    func obtainToken() -> String?
    func saveToken(token: String)
    func savePhotoModels(models: [PhotoRestModel])
    func obtainPhotoModels() -> [PhotoRestModel]
    func saveEmail(_ email: String)
    func obtainEmail() -> String?
}

class SecureStorageService: SecureStorageServiceProtocol {
    
    static let shared: SecureStorageServiceProtocol = SecureStorageService()
    private init() {}
    
    private let storage = UserDefaults.standard
    
    func obtainToken() -> String? {
        storage.string(forKey: "token")
    }
    
    func saveToken(token: String) {
        storage.setValue(token, forKey: "token")
    }
    
    func savePhotoModels(models: [PhotoRestModel]) {
        guard let data = try? JSONEncoder().encode(models) else { return }
        storage.setValue(data, forKey: "photos")
    }
    
    func obtainPhotoModels() -> [PhotoRestModel] {
        guard
            let data = storage.data(forKey: "photos"),
            let photos = try? JSONDecoder().decode([PhotoRestModel].self, from: data)
        else {
            return []
        }
        return photos
    }
    
    func saveEmail(_ email: String) {
        storage.setValue(email, forKey: "email")
    }
    
    func obtainEmail() -> String? {
        storage.string(forKey: "email")
    }
}
