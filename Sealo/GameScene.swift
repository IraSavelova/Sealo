//
//  GameScene.swift
//  Sealo
//
//  Created by Ирина on 06.12.2025.
//

import SpriteKit
import GameplayKit

enum Theme {
    case light
    case dark
}

enum ThemeBack {
    case lightBack
    case darkBack
}

enum BoardShape {
    case cross      // текущее поле
    case triangle   // треугольное
}

class GameScene: SKScene {
    
    // MARK: - Public Properties
    var user: UserData!
    var theme: Theme = .dark
    var themeBack: ThemeBack = .darkBack
    var boardShape: BoardShape = .cross
    
    // MARK: - Private Properties
    private var timerStarted = false
    private var lastElapsedTime: TimeInterval = 0
    private var levelTimerLabel: SKLabelNode!
    private var levelStartTime: TimeInterval?
    private var timerRunning = false
    
    private let rows = 7
    private let cols = 7
    private var cellSize: CGFloat = 50
    
    // Массивы для хранения узлов
    private var background: [[SKSpriteNode?]] = []
    private var board: [[SKSpriteNode?]] = []
    private var pegs: [[Bool]] = []
    
    private var selectedPeg: (row: Int, col: Int)?
    
    // Вычисляемое свойство для лучшего времени
    private var bestTime: TimeInterval {
        get { return user.bestLevelTime }
        set {
            user.bestLevelTime = newValue
            UserDatabase.shared.save()
        }
    }
    
    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        recreateBoard()
    }
    // В GameScene.swift добавьте эти методы:

    // Метод для изменения темы фишек
    func updatePegColors(newTheme: Theme) {
        theme = newTheme
        let pegColor: UIColor = (theme == .dark) ? .blue : .systemPink
        
        // Меняем цвет всех существующих фишек
        for r in 0..<board.count {
            for c in 0..<board[r].count {
                if let peg = board[r][c] {
                    // Не меняем цвет выделенной фишки
                    if selectedPeg?.row != r || selectedPeg?.col != c {
                        peg.color = pegColor
                    }
                }
            }
        }
    }

    // Метод для изменения фона клеток
    func updateBackgroundColors(newTheme: Theme) {
        theme = newTheme
        let bgColor: UIColor = (theme == .dark) ? .gray : .lightGray
        
        // Меняем цвет всех фоновых клеток
        for r in 0..<background.count {
            for c in 0..<background[r].count {
                if let bg = background[r][c] {
                    bg.color = bgColor
                }
            }
        }
    }

    // Метод для изменения общего фона
    func updateSceneBackground(newThemeBack: ThemeBack) {
        themeBack = newThemeBack
        self.backgroundColor = (themeBack == .darkBack) ? .darkGray : .white
    }
    // MARK: - Public Methods
    func recreateBoard() {
        // Очищаем все узлы
        removeAllChildren()
        
        // Инициализируем массивы
        background = Array(repeating: Array(repeating: nil, count: cols), count: rows)
        board = Array(repeating: Array(repeating: nil, count: cols), count: rows)
        pegs = Array(repeating: Array(repeating: false, count: cols), count: rows)
        
        // Устанавливаем фон
        applyBackgroundTheme()
        
        // Создаем доску
        createBoard()
        
        // Настраиваем таймер
        setupTimerLabel()
    }
    
    func updateTheme(newTheme: Theme, newThemeBack: ThemeBack) {
        theme = newTheme
        themeBack = newThemeBack
        recreateBoard()
    }
    
    // MARK: - Board Creation
    private func createBoard() {
        switch boardShape {
        case .cross:
            createCrossBoard()
        case .triangle:
            createTriangleBoard()
        }
    }
    
    private func createCrossBoard() {
        cellSize = min(size.width / CGFloat(cols),
                       size.height / CGFloat(rows)) * 0.9
        
        let startX = size.width / 2 - CGFloat(cols) / 2 * cellSize + cellSize / 2
        let startY = size.height / 2 - CGFloat(rows) / 2 * cellSize + cellSize / 2
        
        for r in 0..<rows {
            for c in 0..<cols {
                // Пропускаем углы для креста
                if (r < 2 || r > 4) && (c < 2 || c > 4) { continue }
                
                let pos = CGPoint(
                    x: startX + CGFloat(c) * cellSize,
                    y: startY + CGFloat(r) * cellSize
                )
                
                createCell(row: r, col: c, position: pos)
            }
        }
        
        // Удаляем центральную фишку
        let center = rows / 2
        if isValidPosition(row: center, col: center) {
            removePeg(row: center, col: center)
        }
    }
    
    private func createTriangleBoard() {
        cellSize = min(size.width / CGFloat(rows),
                       size.height / CGFloat(rows)) * 0.9
        
        let rowHeight = cellSize * 0.866
        let triangleHeight = CGFloat(rows - 1) * rowHeight
        let centerX = size.width / 2
        let startY = size.height / 2 + triangleHeight / 2
        
        // Для треугольника используем разные размеры массивов
        let triangleRows = rows
        var triangleColsPerRow: [Int] = []
        
        // Сначала очищаем и создаем новые массивы под треугольник
        background = []
        board = []
        pegs = []
        
        for r in 0..<triangleRows {
            let colsInRow = r + 1
            triangleColsPerRow.append(colsInRow)
            
            // Добавляем строки в массивы
            background.append(Array(repeating: nil, count: colsInRow))
            board.append(Array(repeating: nil, count: colsInRow))
            pegs.append(Array(repeating: false, count: colsInRow))
        }
        
        // Создаем ячейки
        for r in 0..<triangleRows {
            let colsInRow = r + 1
            let rowWidth = CGFloat(colsInRow - 1) * cellSize
            let startX = centerX - rowWidth / 2
            
            for c in 0..<colsInRow {
                let pos = CGPoint(
                    x: startX + CGFloat(c) * cellSize,
                    y: startY - CGFloat(r) * rowHeight
                )
                
                createCell(row: r, col: c, position: pos)
            }
        }
        
        // Удаляем центральную фишку для треугольника
        let centerRow = triangleRows / 2 + 1
        let centerCol = max(0, triangleColsPerRow[centerRow] / 2)
        if isValidPosition(row: centerRow, col: centerCol) {
            removePeg(row: centerRow, col: centerCol)
        }
    }
    
    private func createCell(row: Int, col: Int, position: CGPoint) {
        // Проверяем границы массивов
        guard isValidPosition(row: row, col: col) else { return }
        
        // Создаем фон
        let bgColor: UIColor = (theme == .dark) ? .gray : .lightGray
        let bg = SKSpriteNode(
            color: bgColor,
            size: CGSize(width: cellSize * 0.82, height: cellSize * 0.82)
        )
        bg.position = position
        bg.zPosition = 0
        addChild(bg)
        background[row][col] = bg
        
        // Создаем фишку
        let pegColor: UIColor = (theme == .dark) ? .blue : .systemPink
        let peg = SKSpriteNode(
            color: pegColor,
            size: CGSize(width: cellSize * 0.8, height: cellSize * 0.8)
        )
        peg.position = position
        peg.zPosition = 1
        addChild(peg)
        
        board[row][col] = peg
        pegs[row][col] = true
    }
    
    private func removePeg(row: Int, col: Int) {
        guard isValidPosition(row: row, col: col) else { return }
        
        board[row][col]?.removeFromParent()
        board[row][col] = nil
        pegs[row][col] = false
    }
    
    // MARK: - Theme Methods
    private func applyBackgroundTheme() {
        switch themeBack {
        case .darkBack:
            self.backgroundColor = .darkGray
        case .lightBack:
            self.backgroundColor = .white
        }
    }
    
    // MARK: - Timer Methods
    private func setupTimerLabel() {
        levelTimerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        levelTimerLabel.fontSize = 20
        levelTimerLabel.fontColor = .systemCyan
        levelTimerLabel.horizontalAlignmentMode = .left
        levelTimerLabel.verticalAlignmentMode = .top
        levelTimerLabel.position = CGPoint(x: 16, y: size.height - 16)
        levelTimerLabel.zPosition = 100
        addChild(levelTimerLabel)
        levelTimerLabel.text = "Время: 0.0s"
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !timerStarted {
            startLevelTimer(currentTime: currentTime)
            timerStarted = true
        }
        
        guard timerRunning, let start = levelStartTime else { return }
        
        let elapsed = currentTime - start
        lastElapsedTime = elapsed
        
        levelTimerLabel.text = String(format: "Время: %.1f s", elapsed)
    }
    
    private func startLevelTimer(currentTime: TimeInterval) {
        levelStartTime = currentTime
        timerRunning = true
    }
    
    private func stopLevelTimer() {
        timerRunning = false
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Проверяем нажатие на кнопку рестарта
        if let node = self.atPoint(location) as? SKLabelNode,
           node.name == "restart_button" {
            restartGame()
            return
        }
        
        // Игнорируем другие нажатия если Game Over открыто
        if childNode(withName: "gameover_dim") != nil {
            return
        }
        
        // Обработка обычного нажатия
        handleTouch(at: location)
    }
    
    private func handleTouch(at point: CGPoint) {
        guard let (row, col) = nodeAtPoint(point) else { return }
        
        if let selected = selectedPeg {
            if canMove(from: selected, to: (row, col)) {
                movePeg(from: selected, to: (row, col))
            }
            
            // Снимаем подсветку
            if isValidPosition(row: selected.row, col: selected.col),
               let selPeg = board[selected.row][selected.col] {
                selPeg.color = (theme == .dark) ? .blue : .systemPink
            }
            
            selectedPeg = nil
        } else {
            if isValidPosition(row: row, col: col),
               pegs[row][col],
               let peg = board[row][col] {
                selectedPeg = (row, col)
                peg.color = .green
            }
        }
    }
    
    private func nodeAtPoint(_ point: CGPoint) -> (Int, Int)? {
        for r in 0..<background.count {
            for c in 0..<background[r].count {
                if let bg = background[r][c], bg.contains(point) {
                    return (r, c)
                }
                if let peg = board[r][c], peg.contains(point) {
                    return (r, c)
                }
            }
        }
        return nil
    }
    
    // MARK: - Game Logic
    private func canMove(from: (Int, Int), to: (Int, Int)) -> Bool {
        // Проверяем границы
        guard isValidPosition(row: to.0, col: to.1),
              isValidPosition(row: from.0, col: from.1) else { return false }
        
        // Проверяем, что целевая ячейка существует и пуста
        if background[to.0][to.1] == nil { return false }
        if pegs[to.0][to.1] { return false }
        
        let dr = to.0 - from.0
        let dc = to.1 - from.1
        
        switch boardShape {
        case .cross:
            // Вертикальный прыжок
            if abs(dr) == 2 && dc == 0 {
                let mid = (from.0 + dr/2, from.1)
                return isValidPosition(row: mid.0, col: mid.1) && pegs[mid.0][mid.1]
            }
            
            // Горизонтальный прыжок
            if abs(dc) == 2 && dr == 0 {
                let mid = (from.0, from.1 + dc/2)
                return isValidPosition(row: mid.0, col: mid.1) && pegs[mid.0][mid.1]
            }
            
        case .triangle:
            // 6 направлений для треугольника
            let validMoves = [
                (-2, 0), (2, 0),
                (0, -2), (0, 2),
                (-2, -2), (2, 2)
            ]
            
            if validMoves.contains(where: { $0.0 == dr && $0.1 == dc }) {
                let mid = (from.0 + dr/2, from.1 + dc/2)
                return isValidPosition(row: mid.0, col: mid.1) && pegs[mid.0][mid.1]
            }
        }
        
        return false
    }
    
    private func movePeg(from: (Int, Int), to: (Int, Int)) {
        let mid = ((from.0 + to.0)/2, (from.1 + to.1)/2)
        
        // Удаляем среднюю фишку
        if isValidPosition(row: mid.0, col: mid.1),
           let midPeg = board[mid.0][mid.1] {
            midPeg.removeFromParent()
            board[mid.0][mid.1] = nil
            pegs[mid.0][mid.1] = false
        }
        
        // Двигаем фишку
        guard isValidPosition(row: from.0, col: from.1),
              let peg = board[from.0][from.1],
              isValidPosition(row: to.0, col: to.1),
              let bgTarget = background[to.0][to.1] else { return }
        
        let moveAction = SKAction.move(to: bgTarget.position, duration: 0.18)
        peg.run(moveAction)
        
        // Обновляем логику
        board[from.0][from.1] = nil
        pegs[from.0][from.1] = false
        
        board[to.0][to.1] = peg
        pegs[to.0][to.1] = true
        
        peg.color = (theme == .dark) ? .blue : .systemPink
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.checkWinCondition() {
                self.showWinWindow()
            } else if !self.anyMovesAvailable() {
                self.gameOver()
            }
        }
    }
    
    private func checkWinCondition() -> Bool {
        var pegCount = 0
        for r in 0..<pegs.count {
            for c in 0..<pegs[r].count {
                if pegs[r][c] {
                    pegCount += 1
                }
            }
        }
        return pegCount == 1
    }
    
    private func anyMovesAvailable() -> Bool {
        for r in 0..<pegs.count {
            for c in 0..<pegs[r].count {
                if !pegs[r][c] { continue }
                if !isValidPosition(row: r, col: c) || background[r][c] == nil { continue }
                
                let dirs: [(Int, Int)]
                
                switch boardShape {
                case .cross:
                    dirs = [(-2, 0), (2, 0), (0, -2), (0, 2)]
                case .triangle:
                    dirs = [
                        (-2, 0), (2, 0),
                        (0, -2), (0, 2),
                        (-2, -2), (2, 2)
                    ]
                }
                
                for dir in dirs {
                    let r2 = r + dir.0
                    let c2 = c + dir.1
                    let rMid = r + dir.0/2
                    let cMid = c + dir.1/2
                    
                    // Проверяем границы
                    guard isValidPosition(row: r2, col: c2),
                          isValidPosition(row: rMid, col: cMid) else { continue }
                    
                    if background[r2][c2] == nil { continue }
                    
                    if pegs[rMid][cMid] && !pegs[r2][c2] {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // MARK: - Helper Methods
    private func isValidPosition(row: Int, col: Int) -> Bool {
        switch boardShape {
        case .cross:
            return row >= 0 && row < rows && col >= 0 && col < cols
        case .triangle:
            return row >= 0 && row < pegs.count && col >= 0 && col < pegs[row].count
        }
    }
    
    private func restartGame() {
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = self.scaleMode
        newScene.user = user
        newScene.boardShape = boardShape
        newScene.theme = theme
        newScene.themeBack = themeBack
        
        let transition = SKTransition.fade(withDuration: 0.4)
        self.view?.presentScene(newScene, transition: transition)
    }
    
    private func gameOver() {
        stopLevelTimer()
        showGameOverWindow()
    }
    
    // MARK: - UI Windows
    private func showGameOverWindow() {
        // Затемняющий фон
        let dim = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.75), size: size)
        dim.position = CGPoint(x: size.width/2, y: size.height/2)
        dim.zPosition = 50
        dim.name = "gameover_dim"
        addChild(dim)
        
        // Панель
        let panelSize = CGSize(width: size.width * 0.75, height: size.height * 0.36)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 28)
        panel.fillColor = .white
        panel.strokeColor = UIColor(white: 0.9, alpha: 1.0)
        panel.position = CGPoint(x: size.width/2, y: size.height/2)
        panel.zPosition = 51
        panel.name = "gameover_panel"
        addChild(panel)
        
        // Текст
        let label = SKLabelNode(text: "GAME OVER")
        label.fontSize = 45
        label.fontColor = .black
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.fontName = "AvenirNext-Bold"
        label.position = CGPoint(x: 0, y: panelSize.height * 0.18)
        label.zPosition = 52
        panel.addChild(label)
        
        // Кнопка
        let buttonWidth = panelSize.width * 0.62
        let buttonHeight: CGFloat = 56
        let button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 14)
        button.fillColor = UIColor(white: 0.87, alpha: 1.0)
        button.strokeColor = UIColor(white: 0.75, alpha: 1.0)
        button.zPosition = 52
        button.name = "restart_button_bg"
        button.position = CGPoint(x: 0, y: -panelSize.height * 0.20)
        panel.addChild(button)
        
        let btnLabel = SKLabelNode(text: "Начать новую игру")
        btnLabel.fontSize = 20
        btnLabel.fontColor = .black
        btnLabel.horizontalAlignmentMode = .center
        btnLabel.verticalAlignmentMode = .center
        btnLabel.fontName = "AvenirNext-Medium"
        btnLabel.position = CGPoint(x: 0, y: -2)
        btnLabel.zPosition = 53
        btnLabel.name = "restart_button"
        button.addChild(btnLabel)
    }
    
    private func showWinWindow() {
        stopLevelTimer()
        
        // Сохраняем лучшее время
        if let start = levelStartTime {
            let elapsed = lastElapsedTime
            if bestTime == 0 || elapsed < bestTime {
                bestTime = elapsed
            }
        }
        
        // Затемняющий фон
        let dim = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.75), size: size)
        dim.position = CGPoint(x: size.width/2, y: size.height/2)
        dim.zPosition = 50
        dim.name = "win_dim"
        addChild(dim)
        
        // Панель
        let panelSize = CGSize(width: size.width * 0.75, height: size.height * 0.36)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 28)
        panel.fillColor = .white
        panel.strokeColor = UIColor(white: 0.9, alpha: 1.0)
        panel.position = CGPoint(x: size.width/2, y: size.height/2)
        panel.zPosition = 51
        panel.name = "win_panel"
        addChild(panel)
        
        // Текст
        let label = SKLabelNode(text: "YOU WIN!")
        label.fontSize = 45
        label.fontColor = .black
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.fontName = "AvenirNext-Bold"
        label.position = CGPoint(x: 0, y: panelSize.height * 0.18)
        label.zPosition = 52
        panel.addChild(label)
        
        // Время
        let timeLabel = SKLabelNode(text: String(format: "Время: %.1f s", lastElapsedTime))
        timeLabel.fontSize = 20
        timeLabel.fontColor = .darkGray
        timeLabel.horizontalAlignmentMode = .center
        timeLabel.verticalAlignmentMode = .center
        timeLabel.fontName = "AvenirNext-Medium"
        timeLabel.position = CGPoint(x: 0, y: 0)
        timeLabel.zPosition = 52
        panel.addChild(timeLabel)
        
        // Кнопка
        let buttonWidth = panelSize.width * 0.62
        let buttonHeight: CGFloat = 56
        let button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 14)
        button.fillColor = UIColor(white: 0.87, alpha: 1.0)
        button.strokeColor = UIColor(white: 0.75, alpha: 1.0)
        button.zPosition = 52
        button.name = "restart_button_bg"
        button.position = CGPoint(x: 0, y: -panelSize.height * 0.25)
        panel.addChild(button)
        
        let btnLabel = SKLabelNode(text: "Начать новую игру")
        btnLabel.fontSize = 20
        btnLabel.fontColor = .black
        btnLabel.horizontalAlignmentMode = .center
        btnLabel.verticalAlignmentMode = .center
        btnLabel.fontName = "AvenirNext-Medium"
        btnLabel.position = CGPoint(x: 0, y: -2)
        btnLabel.zPosition = 53
        btnLabel.name = "restart_button"
        button.addChild(btnLabel)
    }
}

