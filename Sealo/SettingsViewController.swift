import UIKit

class SettingsViewController: UIViewController {
    var user: UserData!
    private var isDarkTheme = true
    private var isDarkThemeBack = true
    private var panel: UIView!
    
    var onThemeChanged: ((Theme) -> Void)?
    var onThemeChangedBack: ((ThemeBack) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        panel = UIView()
        panel.layer.cornerRadius = 30
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)
        updatePanelTheme()
        
        NSLayoutConstraint.activate([
            panel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            panel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            panel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.82),
            panel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
        
        let title = UILabel()
        title.text = "Настройки"
        title.font = UIFont(name: "AvenirNext-Bold", size: 34)
        title.textColor = isDarkTheme ? .black : .white
        title.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(title)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: panel.topAnchor, constant: 28),
            title.centerXAnchor.constraint(equalTo: panel.centerXAnchor)
        ])
        
        let buttons = [
            makeSettingsButton(title: "Изменить цвет фишек"),
            makeSettingsButton(title: "Изменить цвет фона"),
            makeSettingsButton(title: "Звук"),
            makeSettingsButton(title: "Выйти в главное меню"),
            makeCloseButton()
        ]
        
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            stack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 30),
            stack.widthAnchor.constraint(equalTo: panel.widthAnchor, multiplier: 0.8)
        ])
        
        /*let closeBtn = makeCloseButton()
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(closeBtn)
        NSLayoutConstraint.activate([
            closeBtn.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -24),
            closeBtn.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            closeBtn.widthAnchor.constraint(equalTo: panel.widthAnchor, multiplier: 0.6),
            closeBtn.heightAnchor.constraint(equalToConstant: 52)
        ])*/
    }
    
    private func updatePanelTheme() {
        panel.backgroundColor = isDarkTheme ? .white : UIColor(white: 0.15, alpha: 1.0)
    }
    
    private func makeSettingsButton(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 16
        btn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 22)
        btn.heightAnchor.constraint(equalToConstant: 55).isActive = true
        btn.addTarget(self, action: #selector(settingTapped(_:)), for: .touchUpInside)
        return btn
    }
    
    private func makeCloseButton() -> UIButton {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        btn.setTitle("Закрыть", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 16
        btn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 22)
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return btn
    }
    
    @objc private func settingTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        if title == "Изменить цвет фишек" {
            isDarkTheme.toggle()
            onThemeChanged?(isDarkTheme ? .dark : .light)
        }
        if title == "Изменить цвет фона" {
            isDarkThemeBack.toggle()
            onThemeChangedBack?(isDarkThemeBack ? .darkBack : .lightBack)
        }
            else {
            print("Setting pressed: \(title)")
        }
        if title == "Выйти в главное меню" {
            let menuVC = MainMenuViewController(user: user)
            menuVC.modalPresentationStyle = .fullScreen

            view.window?.rootViewController = menuVC
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
}



