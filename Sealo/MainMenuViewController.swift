//
//  MainMenuViewController.swift
//  Sealo
//
//  Created by Ирина on 12.12.2025.


import UIKit
import SpriteKit

class MainMenuViewController: UIViewController {

    let user: UserData

    init(user: UserData) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        // Приветствие
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Привет, \(user.username ?? "Гость")!"
        welcomeLabel.font = UIFont(name: "AvenirNext-Bold", size: 28)
        welcomeLabel.textAlignment = .center
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(welcomeLabel)

        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // Кнопки меню
        let buttonTitles = [
            "Начать новую игру",
            "Достижения",
            "Правила игры",
            "Магазин",
            "Получить ежедневный приз",
            "Игра фортуна",
            "Пройти обучение",
            "Профиль",
            "Челленджи",
            "Создать свой уровень"
        ]

        var buttons = [UIButton]()
        for title in buttonTitles {
            let btn = makeButton(title)
            buttons.append(btn)
        }

        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 40),
            stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75)
        ])
    }

    private func makeButton(_ title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 14
        btn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20)
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return btn
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }

        switch title {
        case "Начать новую игру":
            let gameVC = GameViewController()
            gameVC.user = user
            gameVC.modalPresentationStyle = .fullScreen
            present(gameVC, animated: true)
        case "Пройти обучение":
            let tutorialVC = TutorialViewController()
            tutorialVC.modalPresentationStyle = .overFullScreen
            present(tutorialVC, animated: true, completion: nil)
        case "Создать свой уровень":
            let editorVC = LevelEditorViewController()
                editorVC.modalPresentationStyle = .fullScreen
                present(editorVC, animated: true)
        case "Игра фортуна":
            let skVC = UIViewController()
            skVC.modalPresentationStyle = .fullScreen

            let skView = SKView(frame: UIScreen.main.bounds)
            skVC.view = skView

            let scene = FortuneScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            scene.parentVC = skVC
            // Передаём объект пользователя
            scene.user = user

            // Обновление баланса
            scene.onBalanceUpdate = { [weak self] newBalance in
                guard let self = self else { return }
                self.user.balance = Int64(newBalance)
                UserDatabase.shared.save()
            }

            skView.presentScene(scene)
            present(skVC, animated: true)

        case "Получить ежедневный приз":
            let prizVC = DailyPrizeViewController(user:user)
            prizVC.modalPresentationStyle = .overFullScreen
            present(prizVC, animated: true)
        case "Правила игры":
            let rulesVC = RulesViewController()
                rulesVC.modalPresentationStyle = .fullScreen
                present(rulesVC, animated: true)
        case "Магазин":
            let shopVC = ShopViewController(user:user)
            shopVC.modalPresentationStyle = .overFullScreen
            present(shopVC, animated: true)
        case "Профиль":
            let profileVC = ProfileViewController(user:user)
            profileVC.modalPresentationStyle = .overFullScreen
            present(profileVC, animated: true)
        case "Достижения":
            let achievementsVC = LeaderboardViewController()
                achievementsVC.modalPresentationStyle = .overFullScreen
                present(achievementsVC, animated: true)
        case "Челленджи":
            let challengesVC = ChallengesViewController()
                challengesVC.modalPresentationStyle = .fullScreen
                present(challengesVC, animated: true)
        default:
            let alert = UIAlertController(title: title, message: "Эта функция пока не реализована.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

