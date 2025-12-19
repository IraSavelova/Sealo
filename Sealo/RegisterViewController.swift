//
//  RegisterViewController.swift
//  Sealo
//
//  Created by Ирина on 12.12.2025.
//

import UIKit

class RegisterViewController: UIViewController {
    let userField = UITextField()
    let passField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupField(userField, placeholder: "Имя")
        setupField(passField, placeholder: "Пароль")
        
        let registerButton = UIButton(type: .system)
        registerButton.setTitle("Создать аккаунт", for: .normal)
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(registerButton)

        let stack = UIStackView(arrangedSubviews: [userField, passField])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),

            registerButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 30),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func setupField(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
    }

    @objc private func registerTapped() {
        guard let u = userField.text, !u.isEmpty,
              let p = passField.text, !p.isEmpty else { return }

        UserDatabase.shared.createUser(username: u, password: p)
        dismiss(animated: true)
    }
}
