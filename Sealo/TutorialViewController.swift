import UIKit

class TutorialViewController: UIViewController {
    
    private let steps = [
        "Шаг 1: Выберите фишку",
        "Шаг 2: Прыгните через соседнюю фишку",
        "Шаг 3: Переместитесь на пустую клетку",
        "Шаг 4: Прыгать можно только по вертикали или горизонтали",
        "Шаг 5: Цель - оставить только одну фишку"
    ]
    
    private let stepDescriptions = [
        "Нажмите на любую фишку, чтобы выбрать её. Выбранная фишка подсветится зелёным цветом.",
        "Вы можете прыгнуть только через фишку, которая находится рядом (через одну клетку).",
        "Переместитесь на пустую клетку, которая находится за фишкой, через которую прыгаете.",
        "Диагональные ходы запрещены.",
        "Старайтесь убрать все фишки кроме одной. Идеальный результат - оставить одну фишку в центре."
    ]
    
    private var currentStep = 0
    private var tutorialBoardView: UIView!
    private var stepLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var prevButton: UIButton!
    private var nextButton: UIButton!
    private var closeButton: UIButton!
    
    // Маленькое игровое поле для демонстрации (3x3 для простоты)
    private let demoRows = 3
    private let demoCols = 3
    private var demoBoard = [[UIView?]]()
    private var demoPegs = [[Bool]]()
    private var selectedDemoPeg: (row: Int, col: Int)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Ждем следующего цикла runloop, когда layout будет готов
        DispatchQueue.main.async {
            self.setupDemoBoard()
            self.showStep(0)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ждем когда layout будет готов, чтобы правильно расположить фишки
        if demoBoard.isEmpty {
            setupDemoBoard()
            showStep(0)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        
        // Основная панель
        let panel = UIView()
        panel.backgroundColor = .white
        panel.layer.cornerRadius = 30
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)
        
        NSLayoutConstraint.activate([
            panel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            panel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            panel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.92),
            panel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.82)
        ])
        
        // Заголовок
        let titleLabel = UILabel()
        titleLabel.text = "Обучение игре"
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 32)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: panel.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -20)
        ])
        
        // Контейнер для демонстрационного поля (фиксированные размеры)
        tutorialBoardView = UIView()
        tutorialBoardView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        tutorialBoardView.layer.cornerRadius = 15
        tutorialBoardView.clipsToBounds = true
        tutorialBoardView.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(tutorialBoardView)
        
        NSLayoutConstraint.activate([
            tutorialBoardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tutorialBoardView.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            tutorialBoardView.widthAnchor.constraint(equalToConstant: 250),
            tutorialBoardView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        // Текущий шаг
        stepLabel = UILabel()
        stepLabel.font = UIFont(name: "AvenirNext-Bold", size: 24)
        stepLabel.textAlignment = .center
        stepLabel.numberOfLines = 0
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(stepLabel)
        
        NSLayoutConstraint.activate([
            stepLabel.topAnchor.constraint(equalTo: tutorialBoardView.bottomAnchor, constant: 25),
            stepLabel.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            stepLabel.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 20),
            stepLabel.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -20)
        ])
        
        // Описание шага
        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 18)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .darkGray
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 12),
            descriptionLabel.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 25),
            descriptionLabel.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -25)
        ])
        
        // Панель для кнопок навигации
        let navigationPanel = UIView()
        navigationPanel.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(navigationPanel)
        
        // Кнопка "Назад"
        prevButton = UIButton(type: .system)
        prevButton.setTitle("← Назад", for: .normal)
        prevButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        prevButton.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
        prevButton.setTitleColor(.darkGray, for: .normal)
        prevButton.layer.cornerRadius = 12
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.addTarget(self, action: #selector(prevStep), for: .touchUpInside)
        navigationPanel.addSubview(prevButton)
        
        // Кнопка "Вперед"
        nextButton = UIButton(type: .system)
        nextButton.setTitle("Вперед →", for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        nextButton.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
        nextButton.setTitleColor(.darkGray, for: .normal)
        nextButton.layer.cornerRadius = 12
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        navigationPanel.addSubview(nextButton)
        
        // Констрейнты для панели навигации
        NSLayoutConstraint.activate([
            navigationPanel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 25),
            navigationPanel.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            navigationPanel.widthAnchor.constraint(equalToConstant: 240),
            navigationPanel.heightAnchor.constraint(equalToConstant: 50),
            
            prevButton.leadingAnchor.constraint(equalTo: navigationPanel.leadingAnchor),
            prevButton.centerYAnchor.constraint(equalTo: navigationPanel.centerYAnchor),
            prevButton.widthAnchor.constraint(equalToConstant: 110),
            prevButton.heightAnchor.constraint(equalToConstant: 44),
            
            nextButton.trailingAnchor.constraint(equalTo: navigationPanel.trailingAnchor),
            nextButton.centerYAnchor.constraint(equalTo: navigationPanel.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 110),
            nextButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Кнопка "Закрыть" (показывается только на последнем шаге)
        closeButton = UIButton(type: .system)
        closeButton.setTitle("Начать игру", for: .normal)
        closeButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 20)
        closeButton.backgroundColor = UIColor(red: 0.1, green: 0.5, blue: 0.9, alpha: 1.0)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 14
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTutorial), for: .touchUpInside)
        closeButton.isHidden = true // Скрыта по умолчанию
        panel.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: navigationPanel.bottomAnchor, constant: 15),
            closeButton.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 180),
            closeButton.heightAnchor.constraint(equalToConstant: 52),
            closeButton.bottomAnchor.constraint(lessThanOrEqualTo: panel.bottomAnchor, constant: -25)
        ])
    }
    
    private func setupDemoBoard() {
        // Очищаем предыдущие фишки
        tutorialBoardView.subviews.forEach { $0.removeFromSuperview() }
        tutorialBoardView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let boardSize: CGFloat = 200
        let cellSize: CGFloat = boardSize / CGFloat(demoCols)
        
        // Центрируем доску внутри tutorialBoardView
        let startX = (tutorialBoardView.bounds.width - boardSize) / 2
        let startY = (tutorialBoardView.bounds.height - boardSize) / 2
        
        // Инициализация массивов
        demoBoard = Array(repeating: Array(repeating: nil, count: demoCols), count: demoRows)
        demoPegs = Array(repeating: Array(repeating: false, count: demoCols), count: demoRows)
        
        // Сначала рисуем фон клеток
        for r in 0..<demoRows {
            for c in 0..<demoCols {
                let x = startX + CGFloat(c) * cellSize
                let y = startY + CGFloat(r) * cellSize
                
                // Фон клетки
                let bgView = UIView(frame: CGRect(x: x + 5, y: y + 5,
                                                 width: cellSize - 10, height: cellSize - 10))
                bgView.backgroundColor = .lightGray
                bgView.layer.cornerRadius = 8
                tutorialBoardView.addSubview(bgView)
            }
        }
        
        // Затем добавляем фишки поверх фона
        for r in 0..<demoRows {
            for c in 0..<demoCols {
                let x = startX + CGFloat(c) * cellSize
                let y = startY + CGFloat(r) * cellSize
                
                // Фишка (все кроме центра на шаге 1, потом меняется)
                let hasPeg = !(r == 1 && c == 1) // все кроме центра
                if hasPeg {
                    let pegView = UIView(frame: CGRect(x: x + 10, y: y + 10,
                                                      width: cellSize - 20, height: cellSize - 20))
                    pegView.backgroundColor = .systemBlue
                    pegView.layer.cornerRadius = (cellSize - 20) / 2
                    pegView.tag = r * 10 + c // уникальный тег для идентификации
                    
                    // Добавляем жесты для демонстрации
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDemoTap(_:)))
                    pegView.addGestureRecognizer(tapGesture)
                    pegView.isUserInteractionEnabled = true
                    
                    tutorialBoardView.addSubview(pegView)
                    demoBoard[r][c] = pegView
                    demoPegs[r][c] = true
                }
            }
        }
    }
    
    @objc private func handleDemoTap(_ gesture: UITapGestureRecognizer) {
        guard let pegView = gesture.view else { return }
        
        let tag = pegView.tag
        let row = tag / 10
        let col = tag % 10
        
        // Демонстрация выбора фишки (только для шага 1)
        if currentStep == 0 {
            // Сбрасываем предыдущий выбор
            if let (prevRow, prevCol) = selectedDemoPeg,
               let prevPeg = demoBoard[prevRow][prevCol] {
                prevPeg.backgroundColor = .systemBlue
                prevPeg.transform = .identity
                prevPeg.layer.removeAllAnimations()
            }
            
            // Выделяем новую фишку
            pegView.backgroundColor = .systemGreen
            selectedDemoPeg = (row, col)
            
            // Анимация пульсации
            UIView.animate(withDuration: 0.6, delay: 0, options: [.autoreverse, .repeat], animations: {
                pegView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }, completion: nil)
        }
    }

    private func showStep(_ stepIndex: Int) {
        currentStep = stepIndex
        
        // Обновляем тексты
        stepLabel.text = steps[stepIndex]
        descriptionLabel.text = stepDescriptions[stepIndex]
        
        // Устанавливаем максимальную ширину для правильного переноса
        let maxWidth = view.bounds.width * 0.9 - 50  // Ширина панели минус отступы
        descriptionLabel.preferredMaxLayoutWidth = maxWidth
        
        // Принудительно обновляем layout
        descriptionLabel.setNeedsLayout()
        descriptionLabel.layoutIfNeeded()
        // Обновляем состояние кнопок
        prevButton.isHidden = (stepIndex == 0)
        nextButton.isHidden = (stepIndex == steps.count - 1)
        closeButton.isHidden = (stepIndex != steps.count - 1) // Показываем только на последнем шаге
        
        // Очищаем поле для демонстрации
        resetDemoBoard()
        setupDemoBoard() // Пересоздаем доску
        
        // Показываем демонстрацию для текущего шага
        switch stepIndex {
        case 0: // Шаг 1: Выбор фишки
            setupStep1()
        case 1: // Шаг 2: Прыжок через фишку
            setupStep2()
        case 2: // Шаг 3: Перемещение на пустую клетку
            setupStep3()
        case 3: // Шаг 4: Направления прыжков
            setupStep4()
        case 4: // Шаг 5: Цель игры
            setupStep5()
        default:
            break
        }
    }
    
    private func resetDemoBoard() {
        // Сбрасываем все фишки к исходному виду
        for r in 0..<demoRows {
            for c in 0..<demoCols {
                if let pegView = demoBoard[r][c] {
                    pegView.backgroundColor = .systemBlue
                    pegView.transform = .identity
                    pegView.layer.removeAllAnimations()
                }
            }
        }
        selectedDemoPeg = nil
        
        // Удаляем все дополнительные слои (стрелки, крестики и т.д.)
        tutorialBoardView.layer.sublayers?.forEach { layer in
            if layer is CAShapeLayer {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    private func setupStep1() {
        // Подсвечиваем все фишки как доступные для выбора
        for r in 0..<demoRows {
            for c in 0..<demoCols {
                if let pegView = demoBoard[r][c] {
                    // Мигающая анимация для привлечения внимания
                    UIView.animate(withDuration: 0.8, delay: Double(r + c) * 0.1,
                                 options: [.repeat, .autoreverse], animations: {
                        pegView.alpha = 0.7
                    }, completion: nil)
                }
            }
        }
    }
    
    private func setupStep2() {
        // Показываем возможный прыжок сверху вниз
        if let topPeg = demoBoard[0][1] {
            topPeg.backgroundColor = .systemGreen
            
            // Создаем копию фишки для анимации прыжка
            let jumpingPeg = UIView(frame: topPeg.frame)
            jumpingPeg.backgroundColor = .systemGreen
            jumpingPeg.layer.cornerRadius = topPeg.layer.cornerRadius
            tutorialBoardView.addSubview(jumpingPeg)
            
            // Подсвечиваем фишку, через которую прыгаем
            if let middlePeg = demoBoard[1][1] {
                middlePeg.backgroundColor = .systemOrange
                
                // Анимация прыжка
                UIView.animate(withDuration: 1.2, delay: 0.5, options: [.curveEaseInOut], animations: {
                    jumpingPeg.center.y = middlePeg.center.y + (middlePeg.frame.height)
                }, completion: { _ in
                    jumpingPeg.removeFromSuperview()
                    // Повторяем анимацию
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.setupStep2()
                    }
                })
            }
        }
    }
    
    private func setupStep3() {
        let boardSize: CGFloat = 200
        let cellSize: CGFloat = boardSize / CGFloat(demoCols)
        let startX = (tutorialBoardView.bounds.width - boardSize) / 2
        let startY = (tutorialBoardView.bounds.height - boardSize) / 2
        
        let emptyCellX = startX + CGFloat(1) * cellSize
        let emptyCellY = startY + CGFloat(1) * cellSize
        
        // Создаем индикатор пустой клетки
        let emptyIndicator = UIView(frame: CGRect(x: emptyCellX + 5, y: emptyCellY + 5,
                                                 width: cellSize - 10, height: cellSize - 10))
        emptyIndicator.backgroundColor = .clear
        emptyIndicator.layer.borderWidth = 3
        emptyIndicator.layer.borderColor = UIColor.systemRed.cgColor
        emptyIndicator.layer.cornerRadius = 8
        tutorialBoardView.addSubview(emptyIndicator)
        
        // Анимация мигания пустой клетки
        UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat, .autoreverse], animations: {
            emptyIndicator.alpha = 0.4
        }, completion: nil)
        
        // Показываем фишку, которая может прыгнуть в пустую клетку
        if let leftPeg = demoBoard[1][0] {
            leftPeg.backgroundColor = .systemGreen
            
            // Анимация стрелки от фишки к пустой клетке
            addArrow(from: CGPoint(x: leftPeg.center.x + 25, y: leftPeg.center.y),
                    to: CGPoint(x: emptyIndicator.center.x - 25, y: emptyIndicator.center.y),
                    color: .systemGreen)
        }
    }
    
    private func setupStep4() {
        let boardSize: CGFloat = 200
        let cellSize: CGFloat = boardSize / CGFloat(demoCols)
        let startX = (tutorialBoardView.bounds.width - boardSize) / 2
        let startY = (tutorialBoardView.bounds.height - boardSize) / 2
        
        let centerX = startX + cellSize * 1.5
        let centerY = startY + cellSize * 1.5
        
        // Показываем разрешенные направления (синие стрелки)
        let directions: [(dx: CGFloat, dy: CGFloat)] = [
            (0, -1.5),   // вверх
            (0, 1.5),    // вниз
            (-1.5, 0),   // влево
            (1.5, 0)     // вправо
        ]
        
        for direction in directions {
            let endX = centerX + direction.dx * cellSize
            let endY = centerY + direction.dy * cellSize
            addArrow(from: CGPoint(x: centerX, y: centerY),
                    to: CGPoint(x: endX, y: endY),
                    color: .systemBlue)
        }
        
        // Показываем запрещенные направления (красные крестики)
        let diagonals: [(dx: CGFloat, dy: CGFloat)] = [
            (-1, -1),   // вверх-влево
            (1, -1),    // вверх-вправо
            (-1, 1),    // вниз-влево
            (1, 1)      // вниз-вправо
        ]
        
        for diagonal in diagonals {
            let x = centerX + diagonal.dx * cellSize * 0.7
            let y = centerY + diagonal.dy * cellSize * 0.7
            addCross(at: CGPoint(x: x, y: y), color: .systemRed)
        }
    }
    
    private func setupStep5() {
        // Показываем цель - одна фишка в центре
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Анимация исчезновения всех фишек кроме центральной
            for r in 0..<self.demoRows {
                for c in 0..<self.demoCols {
                    if let pegView = self.demoBoard[r][c] {
                        if r == 1 && c == 1 {
                            // Оставляем только центральную фишку
                            UIView.animate(withDuration: 0.8, delay: 1.0, options: [], animations: {
                                pegView.backgroundColor = .systemGreen
                                pegView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                            }, completion: nil)
                            
                            // Пульсация успеха
                            UIView.animate(withDuration: 0.6, delay: 2.0, options: [.repeat, .autoreverse], animations: {
                                pegView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                            }, completion: nil)
                        } else {
                            // Показываем исчезновение остальных фишек
                            UIView.animate(withDuration: 0.5, delay: Double(r + c) * 0.2, options: [], animations: {
                                pegView.alpha = 0
                                pegView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                            }, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    private func addArrow(from: CGPoint, to: CGPoint, color: UIColor) {
        let arrowLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: from)
        path.addLine(to: to)
        
        arrowLayer.path = path.cgPath
        arrowLayer.strokeColor = color.cgColor
        arrowLayer.lineWidth = 3
        arrowLayer.fillColor = nil
        arrowLayer.lineCap = .round
        
        // Добавляем стрелку на конце
        let arrowHead = CAShapeLayer()
        let arrowPath = UIBezierPath()
        
        // Вычисляем угол направления
        let angle = atan2(to.y - from.y, to.x - from.x)
        let arrowLength: CGFloat = 10
        
        let point1 = CGPoint(
            x: to.x - arrowLength * cos(angle - .pi/6),
            y: to.y - arrowLength * sin(angle - .pi/6)
        )
        let point2 = CGPoint(
            x: to.x - arrowLength * cos(angle + .pi/6),
            y: to.y - arrowLength * sin(angle + .pi/6)
        )
        
        arrowPath.move(to: to)
        arrowPath.addLine(to: point1)
        arrowPath.addLine(to: point2)
        arrowPath.close()
        
        arrowHead.path = arrowPath.cgPath
        arrowHead.fillColor = color.cgColor
        
        tutorialBoardView.layer.addSublayer(arrowLayer)
        tutorialBoardView.layer.addSublayer(arrowHead)
        
        // Анимация стрелки
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.3
        animation.toValue = 1.0
        animation.duration = 1.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        arrowLayer.add(animation, forKey: "opacity")
        arrowHead.add(animation, forKey: "opacity")
    }
    
    private func addCross(at point: CGPoint, color: UIColor) {
        let size: CGFloat = 20
        
        let crossLayer = CAShapeLayer()
        let path = UIBezierPath()
        
        // Первая линия креста
        path.move(to: CGPoint(x: point.x - size/2, y: point.y - size/2))
        path.addLine(to: CGPoint(x: point.x + size/2, y: point.y + size/2))
        
        // Вторая линия креста
        path.move(to: CGPoint(x: point.x + size/2, y: point.y - size/2))
        path.addLine(to: CGPoint(x: point.x - size/2, y: point.y + size/2))
        
        crossLayer.path = path.cgPath
        crossLayer.strokeColor = color.cgColor
        crossLayer.lineWidth = 3
        crossLayer.fillColor = nil
        crossLayer.lineCap = .round
        
        tutorialBoardView.layer.addSublayer(crossLayer)
        
        // Анимация крестика
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.3
        animation.toValue = 0.8
        animation.duration = 0.8
        animation.autoreverses = true
        animation.repeatCount = .infinity
        crossLayer.add(animation, forKey: "opacity")
    }
    
    @objc private func prevStep() {
        if currentStep > 0 {
            showStep(currentStep - 1)
        }
    }
    
    @objc private func nextStep() {
        if currentStep < steps.count - 1 {
            showStep(currentStep + 1)
        }
    }
    
    @objc private func closeTutorial() {
        dismiss(animated: true, completion: nil)
    }
}
