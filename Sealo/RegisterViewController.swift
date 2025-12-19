import UIKit

class RegisterViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let userField = UITextField()
    let passField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupScrollView()
        setupUI()
        setupKeyboardHandling()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func setupUI() {
        setupField(userField, placeholder: "Имя")
        setupField(passField, placeholder: "Пароль")
        
        // Настройка полей
        userField.autocorrectionType = .no
        userField.autocapitalizationType = .none
        userField.returnKeyType = .next
        userField.delegate = self
        
        passField.isSecureTextEntry = true
        passField.autocorrectionType = .no
        passField.autocapitalizationType = .none
        passField.returnKeyType = .done
        passField.delegate = self
        
        let stack = UIStackView(arrangedSubviews: [userField, passField])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        
        let registerButton = UIButton(type: .system)
        registerButton.setTitle("Создать аккаунт", for: .normal)
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        registerButton.backgroundColor = .systemBlue
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 10
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(registerButton)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -50),
            stack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),

            registerButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 40),
            registerButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            registerButton.widthAnchor.constraint(equalToConstant: 200),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupField(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 16)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    @objc private func registerTapped() {
        hideKeyboard()
        
        guard let u = userField.text?.trimmingCharacters(in: .whitespaces),
              let p = passField.text?.trimmingCharacters(in: .whitespaces) else { return }
        
        if u.isEmpty || p.isEmpty {
            showAlert(message: "Заполните все поля")
            return
        }
        
        if p.count < 4 {
            showAlert(message: "Пароль должен содержать минимум 4 символа")
            return
        }
        
        UserDatabase.shared.createUser(username: u, password: p)
        
        let successAlert = UIAlertController(
            title: "Успешно!",
            message: "Аккаунт создан",
            preferredStyle: .alert
        )
        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(successAlert, animated: true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userField {
            passField.becomeFirstResponder()
        } else if textField == passField {
            registerTapped()
        }
        return true
    }
}
