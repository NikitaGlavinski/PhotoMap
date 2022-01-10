//
//  RegisterViewController.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit

protocol RegisterViewInput: AnyObject {
    func showError(error: Error)
}

class RegisterViewController: UIViewController {
    
    var viewModel: RegisterViewModelProtocol!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.viewDissapeared()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Create account"
        
        addGestures()
    }
    
    private func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func createAccount(_ sender: Any) {
        guard
            let email = emailTextField.text?.lowercased(),
            let password = passwordTextField.text
        else {
            return
        }
        viewModel.createAccount(email: email, password: password)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension RegisterViewController: RegisterViewInput {
    func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
