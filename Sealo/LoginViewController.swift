import UIKit

class LoginViewController: UIViewController {

    let userField = UITextField()
    let passField = UITextField()
    let scrollView = UIScrollView()
    let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupScrollView()
        setupFields()
        setupLoginButton()
        
        // Жест для скрытия клавиатуры
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
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
    
    private func setupFields() {
        userField.placeholder = "Имя"
        userField.borderStyle = .roundedRect
        userField.autocorrectionType = .no
        userField.autocapitalizationType = .none
        userField.returnKeyType = .next
        userField.delegate = self
        
        passField.placeholder = "Пароль"
        passField.borderStyle = .roundedRect
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
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -50),
            stack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7)
        ])
    }
    
    private func setupLoginButton() {
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Войти", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 10
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: passField.bottomAnchor, constant: 40),
            loginButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func loginTapped() {
        hideKeyboard()
        
        guard let u = userField.text?.trimmingCharacters(in: .whitespaces),
              let p = passField.text?.trimmingCharacters(in: .whitespaces) else { return }
        
        if u.isEmpty || p.isEmpty {
            showAlert(message: "Заполните все поля")
            return
        }

        if let user = UserDatabase.shared.fetchUser(username: u, password: p) {
            UserDatabase.shared.updateLastLogin(user: user)
            
            let mainMenuVC = MainMenuViewController(user: user)
            mainMenuVC.modalPresentationStyle = .fullScreen
            present(mainMenuVC, animated: true)
        } else {
            showAlert(message: "Неверное имя пользователя или пароль")
        }
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
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userField {
            passField.becomeFirstResponder()
        } else if textField == passField {
            loginTapped()
        }
        return true
    }
}
