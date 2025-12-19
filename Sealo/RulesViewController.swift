import UIKit

class RulesViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let backButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0)
        
        // Заголовок
        let titleLabel = UILabel()
        titleLabel.text = "📜 Правила игры"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Кнопка назад - ДОБАВЬТЕ TARGET
        backButton.setTitle("← Назад", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside) // ← ДОБАВЬТЕ ЭТУ СТРОКУ
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        // Скролл вью
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Создаем правила
        createRulesContent()
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), // ← ИСПРАВЛЕНО
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func createRulesContent() {
        let rules = [
            ("🎯 Цель игры", "Оставить на поле всего одну фишку"),
            ("🧩 Как играть", "1. Выбирай фишку для прыжка\n2. Перепрыгивай через соседнюю фишку\n3. Приземляйся на пустую клетку\n4. Перепрыгнутая фишка удаляется с поля"),
            ("📍 Правила прыжка", "• Прыгать можно только через 1 фишку\n• Прыгать можно вверх, вниз, влево, вправо\n• На треугольном поле можно прыгать по диагонали"),
            ("⏱️ Таймер", "• Таймер запускается при начале игры\n• Старайся пройти уровень быстрее\n• Лучшее время сохраняется"),
            ("🏆 Два поля", "• Крестовое поле - классический вариант\n• Треугольное поле - более сложный вариант"),
            ("🎨 Настройки", "• Можно менять цвет фишек\n• Можно менять цвет фона\n• Все настройки сохраняются"),
            ("💡 Подсказка", "Планируй ходы заранее!")
        ]
        
        var previousView: UIView?
        
        for (index, rule) in rules.enumerated() {
            let card = createRuleCard(
                title: rule.0,
                description: rule.1,
                index: index
            )
            
            contentView.addSubview(card)
            
            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            ])
            
            if let previous = previousView {
                card.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 15).isActive = true
            } else {
                card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
            }
            
            previousView = card
        }
        
        // ВАЖНО: Привяжите последнюю карточку к низу contentView
        if let lastCard = previousView {
            lastCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
        }
    }
    
    private func createRuleCard(title: String, description: String, index: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 6
        card.layer.shadowOpacity = 0.1
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Эмодзи иконка
        let emojiLabel = UILabel()
        emojiLabel.text = String(title.prefix(2))
        emojiLabel.font = UIFont.systemFont(ofSize: 28)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(emojiLabel)
        
        // Заголовок
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        // Описание
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = UIFont.systemFont(ofSize: 16)
        descLabel.textColor = .darkGray
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(descLabel)
        
        // Констрейнты
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            emojiLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            emojiLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 15),
            emojiLabel.widthAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -15)
        ])
        
        return card
    }
    
    // ДОБАВЬТЕ ЭТОТ МЕТОД
    @objc private func backTapped() {
        dismiss(animated: true)
    }
}
