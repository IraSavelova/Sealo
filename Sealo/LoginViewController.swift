//
//  LoginViewController.swift
//  Sealo
//
//  Created by Ирина on 12.12.2025.
//

import UIKit

class LoginViewController: UIViewController {

    let userField = UITextField()
    let passField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupField(userField, placeholder: "Имя")
        setupField(passField, placeholder: "Пароль")

        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Войти", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)

        let stack = UIStackView(arrangedSubviews: [userField, passField])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),

            loginButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 30),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func setupField(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
    }

    @objc private func loginTapped() {
        guard let u = userField.text,
              let p = passField.text else { return }

        if let user = UserDatabase.shared.fetchUser(username: u, password: p) {
            UserDatabase.shared.updateLastLogin(user: user)
            
            let mainMenuVC = MainMenuViewController(user: user)
            mainMenuVC.modalPresentationStyle = .fullScreen
            present(mainMenuVC, animated: true)
        } else {
            let alert = UIAlertController(title: "Ошибка", message: "Неверные данные", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }


}
