//
//  RegisterViewModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import Foundation

protocol RegisterViewModelProtocol: AnyObject {
    func viewDissapeared()
    func createAccount(email: String, password: String)
}

class RegisterViewModel {
    weak var view: RegisterViewInput!
    var coordinator: RegisterCoordinatorDelegate!
}

extension RegisterViewModel: RegisterViewModelProtocol {
    
    func viewDissapeared() {
        coordinator.goBack()
    }
    
    func createAccount(email: String, password: String) {
        AuthorizationService.shared.createAccount(email: email, password: password) { result in
            switch result {
            case .success(let token):
                SecureStorageService.shared.saveToken(token: token)
                self.coordinator.routeToMainScreen()
            case .failure(let error):
                self.view.showError(error: error)
            }
        }
    }
}
