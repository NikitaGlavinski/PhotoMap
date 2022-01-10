//
//  AuthorizationService.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import Foundation
import Firebase

protocol AuthorizationServiceProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> ())
    func createAccount(email: String, password: String, completion: @escaping (Result<String, Error>) -> ())
}

class AuthorizationService: AuthorizationServiceProtocol {
    
    static let shared: AuthorizationServiceProtocol = AuthorizationService()
    private init() {}
    
    func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let token = authResult?.user.uid else {
                completion(.failure(NetworkError.noData))
                return
            }
            SecureStorageService.shared.saveEmail(email)
            completion(.success(token))
        }
    }
    
    func createAccount(email: String, password: String, completion: @escaping (Result<String, Error>) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let token = authResult?.user.uid else {
                completion(.failure(NetworkError.noData))
                return
            }
            SecureStorageService.shared.saveEmail(email)
            completion(.success(token))
        }
    }
}
