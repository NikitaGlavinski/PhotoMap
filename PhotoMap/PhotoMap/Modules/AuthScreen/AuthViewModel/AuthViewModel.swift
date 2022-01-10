//
//  AuthViewModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import Foundation

protocol AuthViewModelProtocol: AnyObject {
    func signIn(email: String, password: String)
    func createAccount()
}

class AuthViewModel {
    weak var view: AuthViewInput!
    var coordinator: AuthCoordinatorDelegate!
}

extension AuthViewModel: AuthViewModelProtocol {
    
    func signIn(email: String, password: String) {
        AuthorizationService.shared.signIn(email: email, password: password) { result in
            switch result {
            case .success(let token):
                SecureStorageService.shared.saveToken(token: token)
                self.coordinator.routeToMainScreen()
            case .failure(let error):
                self.view.showError(error: error)
            }
        }
    }
    
    func createAccount() {
        coordinator.routeToRegister()
    }
}
