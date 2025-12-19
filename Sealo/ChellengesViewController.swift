//
//  ChallengesViewController.swift
//  Sealo
//

import UIKit

class ChallengesViewController: UIViewController {
    
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
        titleLabel.text = "Челленджи 🏆"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Кнопка назад
        backButton.setTitle("← Назад", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        // Скролл вью
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Создаем карточки челленджей
        let challenges = [
            ("🎯 Ежедневный игрок", "Заходи в игру 7 дней подряд", "7/7", true, "500"),
            ("⚡️ Треугольный гений", "Пройди треугольный уровень за 30 секунд", "0/30", false, "300"),
            ("🎯 Крестовый мастер", "Пройди крестовый уровень за 30 секунд", "15/30", false, "300"),
            ("🏅 Накопитель очков", "Собери 1000 очков за все время", "340/1000", false, "1000"),
            ("🔄 Мастер прыжков", "Сделай 20 прыжков за одну игру", "0/20", false, "200"),
            ("🔥 Победная серия", "Выиграй 5 игр подряд", "2/5", false, "800"),
            ("👑 Эксперт треугольника", "Пройди треугольный уровень за 15 секунд", "0/15", false, "500"),
            ("⭐️ Эксперт креста", "Пройди крестовый уровень за 15 секунд", "0/15", false, "500")
        ]
        
        var previousView: UIView?
        for (index, challenge) in challenges.enumerated() {
            let card = createChallengeCard(
                title: challenge.0,
                description: challenge.1,
                progress: challenge.2,
                isCompleted: challenge.3,
                reward: challenge.4,
                index: index
            )
            
            contentView.addSubview(card)
            
            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                card.heightAnchor.constraint(equalToConstant: 110)
            ])
            
            if let previous = previousView {
                card.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 15).isActive = true
            } else {
                card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
            }
            
            previousView = card
        }
        
        // Констрейнты
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Последняя карточка должна прижиматься к низу
        if let lastCard = previousView {
            lastCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        }
    }
    
    private func createChallengeCard(title: String, description: String, progress: String,
                                    isCompleted: Bool, reward: String, index: Int) -> UIView {
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
        emojiLabel.text = String(title.prefix(2)) // Берем эмодзи из заголовка
        emojiLabel.font = UIFont.systemFont(ofSize: 32)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(emojiLabel)
        
        // Заголовок
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        // Описание
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = UIFont.systemFont(ofSize: 14)
        descLabel.textColor = .gray
        descLabel.numberOfLines = 2
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(descLabel)
        
        // Прогресс
        let progressLabel = UILabel()
        progressLabel.text = progress
        progressLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        progressLabel.textColor = isCompleted ? .systemGreen : .systemOrange
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(progressLabel)
        
        // Награда
        let rewardView = UIView()
        rewardView.backgroundColor = UIColor(red: 0.9, green: 0.98, blue: 0.9, alpha: 1.0)
        rewardView.layer.cornerRadius = 12
        rewardView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(rewardView)
        
        let coinLabel = UILabel()
        coinLabel.text = "🪙"
        coinLabel.font = UIFont.systemFont(ofSize: 14)
        coinLabel.translatesAutoresizingMaskIntoConstraints = false
        rewardView.addSubview(coinLabel)
        
        let rewardLabel = UILabel()
        rewardLabel.text = reward
        rewardLabel.font = UIFont.boldSystemFont(ofSize: 16)
        rewardLabel.textColor = .systemGreen
        rewardLabel.translatesAutoresizingMaskIntoConstraints = false
        rewardView.addSubview(rewardLabel)
        
        // Статус (галочка или нет)
        let statusView = UIView()
        statusView.backgroundColor = isCompleted ? .systemGreen : UIColor(white: 0.9, alpha: 1.0)
        statusView.layer.cornerRadius = 12
        statusView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(statusView)
        
        let statusIcon = UILabel()
        statusIcon.text = isCompleted ? "✓" : "⋅⋅⋅"
        statusIcon.font = UIFont.boldSystemFont(ofSize: isCompleted ? 16 : 20)
        statusIcon.textColor = isCompleted ? .white : .lightGray
        statusIcon.textAlignment = .center
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusView.addSubview(statusIcon)
        
        // Разноцветные фоны для карточек
        let gradientColors = [
            [UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0), UIColor(red: 0.95, green: 0.98, blue: 1.0, alpha: 1.0)],
            [UIColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 1.0), UIColor(red: 1.0, green: 0.98, blue: 0.95, alpha: 1.0)],
            [UIColor(red: 0.95, green: 1.0, blue: 0.95, alpha: 1.0), UIColor(red: 0.98, green: 1.0, blue: 0.98, alpha: 1.0)],
            [UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0), UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0)]
        ]
        let colors = gradientColors[index % gradientColors.count]
        card.backgroundColor = colors[0]
        
        // Констрейнты
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            emojiLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: -10),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            progressLabel.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            rewardView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            rewardView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            rewardView.widthAnchor.constraint(equalToConstant: 70),
            rewardView.heightAnchor.constraint(equalToConstant: 28),
            
            coinLabel.leadingAnchor.constraint(equalTo: rewardView.leadingAnchor, constant: 8),
            coinLabel.centerYAnchor.constraint(equalTo: rewardView.centerYAnchor),
            
            rewardLabel.leadingAnchor.constraint(equalTo: coinLabel.trailingAnchor, constant: 4),
            rewardLabel.centerYAnchor.constraint(equalTo: rewardView.centerYAnchor),
            rewardLabel.trailingAnchor.constraint(equalTo: rewardView.trailingAnchor, constant: -8),
            
            statusView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            statusView.topAnchor.constraint(equalTo: card.topAnchor, constant: 15),
            statusView.widthAnchor.constraint(equalToConstant: 24),
            statusView.heightAnchor.constraint(equalToConstant: 24),
            
            statusIcon.centerXAnchor.constraint(equalTo: statusView.centerXAnchor),
            statusIcon.centerYAnchor.constraint(equalTo: statusView.centerYAnchor)
        ])
        
        return card
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
    }
}
