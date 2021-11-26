//
//  LoginViewController.swift
//  SignInOptions
//
//  Created by Trevor Schmidt on 4/27/21.
//

import UIKit
import Firebase
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    let rootRef = Database.database().reference()
    
    // scroll for everything
    private let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
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
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.textColor = .label
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.keyboardType = .emailAddress
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
        field.layer.borderWidth = 1
        field.textColor = .label
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.backgroundColor = .secondarySystemBackground
        field.isSecureTextEntry = true
        field.layer.opacity = 0.85
        field.isOpaque = false
        field.textContentType = .password
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Log In"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        // delegates and targets
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
    
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(label)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds

        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                label.frame = CGRect(x: 30, y: 20, width: scrollView.width-60, height: 52)
                emailField.frame = CGRect(x: 30, y: label.bottom+20, width: scrollView.width-60, height: 52)
                passwordField.frame = CGRect(x: 30, y: emailField.bottom+10, width: scrollView.width-60, height: 52)
                loginButton.frame = CGRect(x: 30, y: passwordField.bottom+15, width: scrollView.width-60, height: 52)
            case .pad:
                label.frame = CGRect(x: 30, y: 20, width: scrollView.width-300, height: 52)
                emailField.frame = CGRect(x: 150, y: label.bottom+20, width: scrollView.width-300, height: 52)
                passwordField.frame = CGRect(x: 150, y: emailField.bottom+10, width: scrollView.width-300, height: 52)
                loginButton.frame = CGRect(x: 150, y: passwordField.bottom+15, width: scrollView.width-300, height: 52)
             default:
                break
        }
    }
    
    @objc private func loginButtonTapped() {
        // drop keyboard
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        // error catch
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        // Firebase Login
        Firebase.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let strongSelf = self else {
                return
            }
            // error in login
            guard authResult != nil,
                  error == nil else {
                strongSelf.alertUserLoginError(message: "Username/Password doesn't exist")
                return
            }
            
            // success
            strongSelf.dismiss(animated: true, completion: nil)
        }
    }
    
    func alertUserLoginError(message: String = "Please enter all info to login") {
        let alert = UIAlertController(title: "Whoops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

}
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
}

extension UIView {
    public var width: CGFloat {
        return self.frame.size.width
    }
    public var height: CGFloat {
        return self.frame.size.height
    }
    public var top: CGFloat {
        return self.frame.origin.y
    }
    public var bottom: CGFloat {
        return self.frame.size.height + self.frame.origin.y
    }
    public var left: CGFloat {
        return self.frame.origin.x
    }
    public var right: CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
}
