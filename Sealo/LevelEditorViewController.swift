//
//  LevelEditorViewController.swift
//  Sealo
//

import UIKit

class LevelEditorViewController: UIViewController {
    
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let gridView = UIView()
    private let paletteView = UIView()
    private let actionButtonsView = UIView()
    
    // Элементы сетки (клетки поля)
    private var gridCells: [UIView] = []
    private var activeCells: [[Bool]] = Array(repeating: Array(repeating: false, count: 7), count: 7)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupInitialGrid()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0)
        
        // Кнопка назад
        backButton.setTitle("← Назад", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        // Заголовок
        titleLabel.text = "🎨"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Подзаголовок
        subtitleLabel.text = "Редактор формы поля"
        subtitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        subtitleLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        // Сетка для уровня
        setupGrid()
        
        // Палитра инструментов
        setupPalette()
        
        // Кнопки действий
        setupActionButtons()
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 5),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            gridView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            gridView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gridView.widthAnchor.constraint(equalToConstant: 280),
            gridView.heightAnchor.constraint(equalToConstant: 280),
            
            paletteView.topAnchor.constraint(equalTo: gridView.bottomAnchor, constant: 30),
            paletteView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            paletteView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            paletteView.heightAnchor.constraint(equalToConstant: 80),
            
            actionButtonsView.topAnchor.constraint(equalTo: paletteView.bottomAnchor, constant: 30),
            actionButtonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            actionButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            actionButtonsView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupGrid() {
        gridView.backgroundColor = .white
        gridView.layer.cornerRadius = 16
        gridView.layer.shadowColor = UIColor.black.cgColor
        gridView.layer.shadowOffset = CGSize(width: 0, height: 4)
        gridView.layer.shadowRadius = 8
        gridView.layer.shadowOpacity = 0.1
        gridView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridView)
        
        // Создаем сетку 7x7
        let cellSize: CGFloat = 40
        let spacing: CGFloat = 0
        
        for row in 0..<7 {
            for col in 0..<7 {
                let cell = UIView()
                cell.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0).cgColor
                cell.layer.cornerRadius = 6
                cell.translatesAutoresizingMaskIntoConstraints = false
                gridView.addSubview(cell)
                gridCells.append(cell)
                
                // Добавляем жест нажатия
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
                cell.addGestureRecognizer(tapGesture)
                cell.isUserInteractionEnabled = true
                cell.tag = row * 7 + col // Сохраняем позицию в теге
                
                NSLayoutConstraint.activate([
                    cell.leadingAnchor.constraint(equalTo: gridView.leadingAnchor, constant: CGFloat(col) * (cellSize + spacing)),
                    cell.topAnchor.constraint(equalTo: gridView.topAnchor, constant: CGFloat(row) * (cellSize + spacing)),
                    cell.widthAnchor.constraint(equalToConstant: cellSize),
                    cell.heightAnchor.constraint(equalToConstant: cellSize)
                ])
            }
        }
    }
    
    private func setupInitialGrid() {
        // Начальная форма - крест (как в игре)
        let crossPattern = [
            (2, 2), (2, 3), (2, 4),
            (3, 2), (3, 3), (3, 4),
            (4, 2), (4, 3), (4, 4)
        ]
        
        for (row, col) in crossPattern {
            let index = row * 7 + col
            if index < gridCells.count {
                activateCell(at: row, col: col, animated: false)
            }
        }
    }
    
    private func activateCell(at row: Int, col: Int, animated: Bool = true) {
        guard row >= 0 && row < 7 && col >= 0 && col < 7 else { return }
        
        let index = row * 7 + col
        let cell = gridCells[index]
        
        if activeCells[row][col] {
            // Деактивируем клетку
            activeCells[row][col] = false
            if animated {
                UIView.animate(withDuration: 0.3) {
                    cell.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
                    cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                } completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        cell.transform = .identity
                    }
                }
            } else {
                //в формате RGB
                cell.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
            }
        } else {
            // Активируем клетку
            activeCells[row][col] = true
            if animated {
                cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
                    cell.backgroundColor = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
                    cell.transform = .identity
                }
            } else {
                cell.backgroundColor = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
            }
        }
        
        // Тактильный отклик
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func setupPalette() {
        paletteView.backgroundColor = .white
        paletteView.layer.cornerRadius = 16
        paletteView.layer.shadowColor = UIColor.black.cgColor
        paletteView.layer.shadowOffset = CGSize(width: 0, height: 2)
        paletteView.layer.shadowRadius = 6
        paletteView.layer.shadowOpacity = 0.1
        paletteView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(paletteView)
        
        let paletteTitle = UILabel()
        paletteTitle.text = "Выберите инструмент:"
        paletteTitle.font = UIFont.boldSystemFont(ofSize: 16)
        paletteTitle.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)
        paletteTitle.translatesAutoresizingMaskIntoConstraints = false
        paletteView.addSubview(paletteTitle)
        
        // Инструменты
        let tools = [
            ("➕", "Добавить клетку", UIColor.systemGreen),
            ("➖", "Удалить клетку", UIColor.systemRed),
            ("🎯", "Крестовое поле", UIColor.systemBlue),
            ("🔺", "Треугольное поле", UIColor.systemOrange)
        ]
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        paletteView.addSubview(stack)
        
        for (emoji, title, color) in tools {
            let toolView = createToolView(emoji: emoji, title: title, color: color)
            stack.addArrangedSubview(toolView)
        }
        
        NSLayoutConstraint.activate([
            paletteTitle.topAnchor.constraint(equalTo: paletteView.topAnchor, constant: 15),
            paletteTitle.centerXAnchor.constraint(equalTo: paletteView.centerXAnchor),
            
            stack.topAnchor.constraint(equalTo: paletteTitle.bottomAnchor, constant: 15),
            stack.leadingAnchor.constraint(equalTo: paletteView.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: paletteView.trailingAnchor, constant: -10),
            stack.bottomAnchor.constraint(equalTo: paletteView.bottomAnchor, constant: -15)
        ])
    }
    
    private func createToolView(emoji: String, title: String, color: UIColor) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.backgroundColor = color
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = color.withAlphaComponent(0.7).cgColor
        button.setTitle(emoji, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Назначаем действие в зависимости от инструмента
        switch emoji {
        case "➕":
            button.addTarget(self, action: #selector(addModeTapped), for: .touchUpInside)
        case "➖":
            button.addTarget(self, action: #selector(removeModeTapped), for: .touchUpInside)
        case "🎯":
            button.addTarget(self, action: #selector(crossPatternTapped), for: .touchUpInside)
        case "🔺":
            button.addTarget(self, action: #selector(trianglePatternTapped), for: .touchUpInside)
        default:
            break
        }
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = .darkGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(button)
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupActionButtons() {
        actionButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(actionButtonsView)
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 20
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        actionButtonsView.addSubview(buttonStack)
        
        let buttons = [
            ("Очистить", #selector(clearTapped), UIColor.systemRed),
            ("Сохранить", #selector(saveTapped), UIColor.systemBlue),
            ("🎲 Случайно", #selector(randomTapped), UIColor.systemGreen)
        ]
        
        for (title, selector, color) in buttons {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = color
            button.layer.cornerRadius = 12
            button.addTarget(self, action: selector, for: .touchUpInside)
            button.layer.shadowColor = color.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            button.layer.shadowOpacity = 0.3
            buttonStack.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: actionButtonsView.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: actionButtonsView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: actionButtonsView.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: actionButtonsView.bottomAnchor)
        ])
    }
    
    // MARK: - Обработчики жестов
    
    private var currentMode: EditMode = .add
    
    enum EditMode {
        case add
        case remove
    }
    
    @objc private func cellTapped(_ gesture: UITapGestureRecognizer) {
        guard let cell = gesture.view else { return }
        
        let tag = cell.tag
        let row = tag / 7
        let col = tag % 7
        
        switch currentMode {
        case .add:
            activateCell(at: row, col: col)
        case .remove:
            if activeCells[row][col] {
                activateCell(at: row, col: col)
            }
        }
    }
    
    // MARK: - Обработчики инструментов
    
    @objc private func addModeTapped() {
        currentMode = .add
        showModeMessage("Режим: Добавление клеток")
    }
    
    @objc private func removeModeTapped() {
        currentMode = .remove
        showModeMessage("Режим: Удаление клеток")
    }
    
    @objc private func crossPatternTapped() {
        // Очищаем поле
        clearField(animated: false)
        
        // Устанавливаем крестовый паттерн
        let crossPattern = [
            (2, 2), (2, 3), (2, 4),
            (3, 2), (3, 3), (3, 4),
            (4, 2), (4, 3), (4, 4)
        ]
        
        // Активируем клетки с задержкой для анимации
        for (index, (row, col)) in crossPattern.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                self.activateCell(at: row, col: col, animated: true)
            }
        }
        
        showModeMessage("Установлен крестовый паттерн")
    }
    
    @objc private func trianglePatternTapped() {
        // Очищаем поле
        clearField(animated: false)
        
        // Устанавливаем треугольный паттерн
        var trianglePattern: [(Int, Int)] = []
        for row in 0..<4 {
            for col in 0...row {
                trianglePattern.append((row + 1, col + 2))
            }
        }
        
        // Активируем клетки с задержкой для анимации
        for (index, (row, col)) in trianglePattern.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                self.activateCell(at: row, col: col, animated: true)
            }
        }
        
        showModeMessage("Установлен треугольный паттерн")
    }
    
    // MARK: - Обработчики действий
    
    @objc private func clearTapped() {
        clearField(animated: true)
        showModeMessage("Поле очищено")
    }
    
    @objc private func saveTapped() {
        // Заглушка - показываем сообщение об успешном сохранении
        let alert = UIAlertController(
            title: "Форма сохранена",
            message: "Форма игрового поля успешно сохранена (заглушка)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }
    
    @objc private func randomTapped() {
        // Очищаем поле
        clearField(animated: false)
        
        // Создаем случайную форму
        for row in 0..<7 {
            for col in 0..<7 {
                if Bool.random() {
                    let delay = Double(row * 7 + col) * 0.02
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        self.activateCell(at: row, col: col, animated: true)
                    }
                }
            }
        }
        
        showModeMessage("Случайная форма создана")
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Вспомогательные методы
    
    private func clearField(animated: Bool) {
        for row in 0..<7 {
            for col in 0..<7 {
                if activeCells[row][col] {
                    activeCells[row][col] = false
                    let index = row * 7 + col
                    let cell = gridCells[index]
                    
                    if animated {
                        UIView.animate(withDuration: 0.3, delay: Double(row * 7 + col) * 0.01) {
                            cell.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
                            cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        } completion: { _ in
                            UIView.animate(withDuration: 0.2) {
                                cell.transform = .identity
                            }
                        }
                    } else {
                        cell.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
                    }
                }
            }
        }
        
        if animated {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
    
    private func showModeMessage(_ message: String) {
        // Временное сообщение в верхней части экрана
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        messageLabel.textColor = .white
        messageLabel.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.9)
        messageLabel.textAlignment = .center
        messageLabel.layer.cornerRadius = 8
        messageLabel.clipsToBounds = true
        messageLabel.alpha = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            messageLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        UIView.animate(withDuration: 0.3) {
            messageLabel.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.3) {
                messageLabel.alpha = 0
            } completion: { _ in
                messageLabel.removeFromSuperview()
            }
        }
    }
}
