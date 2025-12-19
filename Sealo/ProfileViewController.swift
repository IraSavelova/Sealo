
import UIKit

class ProfileViewController: UIViewController {

    private let user: UserData

    // UI Elements
    private let panelView = UIView()
    private let stackView = UIStackView()
    private let closeButton = UIButton(type: .system)

    init(user: UserData) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }

    private func setupUI() {
        // Полупрозрачный фон
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        // Панель
        panelView.backgroundColor = .white
        panelView.layer.cornerRadius = 20
        panelView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panelView)
        NSLayoutConstraint.activate([
            panelView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            panelView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            panelView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            panelView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6)
        ])

        // Крестик закрытия
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        closeButton.setTitleColor(.darkGray, for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        panelView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: panelView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // StackView для информации
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        panelView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 70),
            stackView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor, constant: -24)
        ])
    }

    private func populateData() {
        // Имя пользователя
        let nameLabel = makeLabel(title: "Имя:", value: user.username ?? "—")
        stackView.addArrangedSubview(nameLabel)

        // Баланс
        let balanceLabel = makeLabel(title: "Баланс:", value: "\(user.balance) 🪙")
        stackView.addArrangedSubview(balanceLabel)

        // Дата регистрации ???
        

        // Дата последнего входа
        let lastLoginDate = user.lastLoginDate ?? Date()
        let loginLabel = makeLabel(title: "Последний вход:", value: formattedDate(lastLoginDate))
        stackView.addArrangedSubview(loginLabel)

        // Дни подряд захода
        let streak = user.dailyStreak
        let streakLabel = makeLabel(title: "Дней подряд:", value: "\(streak)")
        stackView.addArrangedSubview(streakLabel)

        // Купленные предметы
        let pegColors = (user.ownedPegColors as? [String]) ?? []
        let bgColors = (user.ownedBackgroundColors as? [String]) ?? []

        let ownedItems = (pegColors + bgColors).isEmpty ? "—" : (pegColors + bgColors).joined(separator: ", ")
        let ownedLabel = makeLabel(title: "Куплено:", value: ownedItems)
        stackView.addArrangedSubview(ownedLabel)
    }

    private func makeLabel(title: String, value: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.text = "\(title) \(value)"
        return label
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
