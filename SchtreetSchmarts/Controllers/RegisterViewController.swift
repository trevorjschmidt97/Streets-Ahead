//
//  RegisterViewController.swift
//  SignInOptions
//
//  Created by Trevor Schmidt on 4/27/21.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    let rootRef = Database.database().reference()
    var usernames: [String] = []
    
    private let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Streets Ahead"
        label.textColor = .label
        label.font = label.font.withSize(40)
        label.textAlignment = .center
        return label
    }()
    
    private let nameField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.backgroundColor = .secondarySystemBackground
        field.autocapitalizationType = .words
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "User Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.keyboardType = .default
        field.textColor = .label
        field.layer.opacity = 0.85
        field.isOpaque = false
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.backgroundColor = .secondarySystemBackground
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.keyboardType = .emailAddress
        field.textColor = .label
        field.layer.opacity = 0.85
        field.isOpaque = false
        field.textContentType = .username
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.backgroundColor = .secondarySystemBackground
        field.textColor = .label
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.isSecureTextEntry = true
        field.layer.opacity = 0.85
        field.isOpaque = false
        field.textContentType = .newPassword
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = .systemBackground
        
        // Grab usernames
        rootRef.child("usernames").observeSingleEvent(of: .value) {[weak self]snapshot in
            guard let usernamesdict = snapshot.value as? [String:String] else { return }
            
            var list: [String] = []
            
            for username in usernamesdict.keys {
                list.append(usernamesdict[username]!)
            }
            
            DispatchQueue.main.async {
                self?.usernames = list
            }
        }

        // set delegates and actions
        loginButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
    
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(label)
        scrollView.addSubview(nameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        label.frame = CGRect(x: 30, y: 20, width: scrollView.width-60, height: 52)
        nameField.frame = CGRect(x: 30, y: label.bottom+20, width: scrollView.width-60, height: 52)
        emailField.frame = CGRect(x: 30, y: nameField.bottom+10, width: scrollView.width-60, height: 52)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom+10, width: scrollView.width-60, height: 52)
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom+20, width: scrollView.width-60, height: 52)

    }
    
    @objc private func registerButtonTapped() {
        // drop keyboard
        nameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        // ensure data
        guard let name = nameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !name.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        // check username
        if usernames.contains(name) {
            alertUserLoginError(message: "Username already taken, select other")
            return
        }
        
        // create user
        Firebase.Auth.auth().createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let strongSelf = self else { return }
            
            //error
            guard let result = authResult, error == nil else {
                strongSelf.alertUserLoginError(message: "Error in registration, try different email")
                return
            }
            
            // success
            let user = result.user
            
            // store user
            strongSelf.rootRef.child("users").child(user.uid).setValue([
                "email" : email,
                "name" : name
            ])
            strongSelf.rootRef.child("usernames").child(user.uid).setValue(name)
            
            // dismiss
            strongSelf.dismiss(animated: true, completion: nil)
        }
        
    }
    
    // func to show error
    func alertUserLoginError(message: String = "Please enter all info to register\nPassword must be 6 characters or more") {
        let alert = UIAlertController(title: "Whoops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}
// delegates
extension RegisterViewController: UITextFieldDelegate {
    // return button func
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            registerButtonTapped()
        }
        return true
    }
}
