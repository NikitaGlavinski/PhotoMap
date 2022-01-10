//
//  AuthViewController.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit

protocol AuthViewInput: AnyObject {
    func showError(error: Error)
}

class AuthViewController: UIViewController {
    
    var viewModel: AuthViewModelProtocol!

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sign In"
        
        addGestures()
    }
    
    private func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func signIn(_ sender: Any) {
        guard
            let email = emailTextField.text?.lowercased(),
            let password = passwordTextField.text
        else {
            return
        }
        viewModel.signIn(email: email, password: password)
    }
    
    @IBAction func createAccount(_ sender: Any) {
        viewModel.createAccount()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension AuthViewController: AuthViewInput {
    
    func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
