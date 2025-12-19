//
//  DailyPrizController.swift
//  Sealo
//
//  Created by Ирина on 18.12.2025.
//
import UIKit

class DailyPrizeViewController: UIViewController {

    private let user: UserData
    private let dailyPrizeController: DailyPrizeController

    // UI
    private let backgroundView = UIView()
    private let panelView = UIView()
    private let prizeLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    init(user: UserData) {
        self.user = user
        self.dailyPrizeController = DailyPrizeController(user: user)
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
        showDailyPrize()
    }

    private func setupUI() {
        // Полупрозрачный фон
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Панель
        panelView.backgroundColor = .white
        panelView.layer.cornerRadius = 20
        panelView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panelView)
        NSLayoutConstraint.activate([
            panelView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            panelView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            panelView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            panelView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])

        // Крестик для закрытия
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

        // Лейбл с призом
        // Лейбл с призом
        prizeLabel.font = UIFont.boldSystemFont(ofSize: 28)
        prizeLabel.textColor = .systemYellow
        prizeLabel.textAlignment = .center
        prizeLabel.numberOfLines = 0                // <- разрешаем любое количество строк
        prizeLabel.lineBreakMode = .byWordWrapping // <- перенос слов
        prizeLabel.adjustsFontSizeToFitWidth = true // <- уменьшаем шрифт, если не влезает
        prizeLabel.minimumScaleFactor = 0.5        // <- минимум 50% размера
        prizeLabel.alpha = 0
        prizeLabel.translatesAutoresizingMaskIntoConstraints = false
        panelView.addSubview(prizeLabel)
        NSLayoutConstraint.activate([
            prizeLabel.centerXAnchor.constraint(equalTo: panelView.centerXAnchor),
            prizeLabel.centerYAnchor.constraint(equalTo: panelView.centerYAnchor),
            prizeLabel.leadingAnchor.constraint(equalTo: panelView.leadingAnchor, constant: 16),
            prizeLabel.trailingAnchor.constraint(equalTo: panelView.trailingAnchor, constant: -16)
        ])

    }

    private func showDailyPrize() {
        let prize = dailyPrizeController.claimDailyPrize()

        if prize > 0 {
            prizeLabel.text = "🎉 Ежедневный приз \n+\(prize) 🪙"
        } else {
            prizeLabel.text = "Вы уже получили приз сегодня"
        }

        // Анимация появления
        prizeLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut,
                       animations: {
            self.prizeLabel.alpha = 1
            self.prizeLabel.transform = .identity
        }, completion: nil)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
