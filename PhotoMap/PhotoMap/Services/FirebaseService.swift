//
//  FirebaseService.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/6/21.
//

import Foundation
import Firebase

protocol FirebaseServiceProtocol {
    func setDataAt(path: String, data: PhotoRestModel, completion: @escaping (Result<String, Error>) -> ())
    func getUserPhotos(completion: @escaping (Result<[PhotoRestModel], Error>) -> ())
    func uploadImage(data: Data, completion: @escaping (Result<String, Error>) -> ())
    var updateSignal: (() -> ())? { get set }
}

class FirebaseService: FirebaseServiceProtocol {
    
    static var shared: FirebaseServiceProtocol = FirebaseService()
    
    private init() {}
    
    private let queue = DispatchQueue(label: "FirebaseServiceQueue", qos: .background)
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    var updateSignal: (() -> ())?
    
    private func getListData<T: Decodable>(path: String, type: T.Type, completion: @escaping (Result<[T], Error>) -> (), saveCompletion: @escaping ([T]) -> ()) {
        db.collection(path).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            var items = [T]()
            for document in snapshot?.documents ?? [] {
                guard let item = try? DictionaryDecoder().decode(data: document.data(), type: type) else {
                    completion(.failure(NetworkError.unrecognized))
                    return
                }
                items.append(item)
            }
            saveCompletion(items)
            completion(.success(items))
        }
    }
    
    func setDataAt(path: String, data: PhotoRestModel, completion: @escaping (Result<String, Error>) -> ()) {
        guard let dictionaryData = try? DictionaryEncoder().encode(data) else { return }
        db.document("photos/\(data.id)").setData(dictionaryData) { error in
            self.queue.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success("success"))
                
                var photos = SecureStorageService.shared.obtainPhotoModels()
                guard let index = photos.firstIndex(where: {$0.id == data.id}) else { return }
                photos[index] = data
                SecureStorageService.shared.savePhotoModels(models: photos)
                
                guard let updateSignal = self.updateSignal else { return }
                updateSignal()
            }
        }
    }
    
    func getUserPhotos(completion: @escaping (Result<[PhotoRestModel], Error>) -> ()) {
        getListData(path: "photos", type: PhotoRestModel.self, completion: completion) { photos in
            SecureStorageService.shared.savePhotoModels(models: photos)
            guard let updateSignal = self.updateSignal else { return }
            updateSignal()
        }
    }
    
    func uploadImage(data: Data, completion: @escaping (Result<String, Error>) -> ()) {
        let uploadRef = storage.child(UUID().uuidString)
        uploadRef.putData(data, metadata: nil) { metadata, error in
            self.queue.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                uploadRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let url = url else {
                        completion(.failure(NetworkError.noData))
                        return
                    }
                    completion(.success(url.absoluteString))
                }
            }
        }
    }
}
