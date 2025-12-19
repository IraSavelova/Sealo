//
//  StartViewController.swift
//  Sealo
//
//  Created by Ирина on 12.12.2025.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white

        let titleLabel = UILabel()
        titleLabel.text = "Sealo"
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 46)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 90),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // кнопки
        let authButton = makeButton("Авторизоваться")
        authButton.addTarget(self, action: #selector(openRegister), for: .touchUpInside)

        let loginButton = makeButton("Войти")
        loginButton.addTarget(self, action: #selector(openLogin), for: .touchUpInside)

        let tutorialButton = makeButton("Пройти обучение")
        tutorialButton.addTarget(self, action: #selector(openTutorial), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [authButton, loginButton, tutorialButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.65)
        ])
    }

    private func makeButton(_ title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.black
        btn.layer.cornerRadius = 14
        btn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 22)
        btn.heightAnchor.constraint(equalToConstant: 55).isActive = true
        return btn
    }

    // MARK: — переходы

    @objc private func openRegister() {
        let vc = RegisterViewController()
        present(vc, animated: true)
    }

    @objc private func openLogin() {
        let vc = LoginViewController()
        present(vc, animated: true)
    }

    @objc private func openTutorial() {
        let tutorialVC = TutorialViewController()
                tutorialVC.modalPresentationStyle = .overFullScreen
                present(tutorialVC, animated: true, completion: nil)
    }
}
