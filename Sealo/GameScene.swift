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

class GameScene: SKScene {
    
    var user: UserData!
    var theme: Theme = .dark {
            didSet {
                applyTheme()
            }
        }
    var themeBack: ThemeBack = .darkBack {
            didSet {
                applyThemeBack()
            }
        }
    private func applyThemeBack() {
            
        switch themeBack {
                case .darkBack:
            self.backgroundColor = .darkGray
                case .lightBack:
                    self.backgroundColor = .white
                }
            // Если Game Over открыто — меняем фон
            if let dim = childNode(withName: "gameover_dim") as? SKSpriteNode {
                dim.color = (themeBack == .darkBack) ? UIColor.black.withAlphaComponent(0.75) : UIColor.white.withAlphaComponent(0.6)
            }
        }
    private func applyTheme() {
            // Меняем цвет фона и фишек
            for r in 0..<rows {
                for c in 0..<cols {
                    if let bg = background[r][c] {
                        bg.color = (theme == .dark) ? .gray : .lightGray
                    }
                    if let peg = board[r][c] {
                        peg.color = (theme == .dark) ? .blue : .systemPink
                    }
                }
            }
            
            
        }


    private var timerStarted = false
    private var lastElapsedTime: TimeInterval = 0
    private var levelTimerLabel: SKLabelNode!
    private var levelStartTime: TimeInterval?
    private var timerRunning = false

        // Для хранения лучшего времени
        private var bestTime: TimeInterval {
            get { return user.bestLevelTime }
            set {
                user.bestLevelTime = newValue
                UserDatabase.shared.save()
            }
        }
    private let rows = 7
    private let cols = 7
    private var cellSize: CGFloat = 50
    
    // фон (серые клетки)
    private var background = [[SKSpriteNode?]]()
    // фишки (синие)
    private var board = [[SKSpriteNode?]]()
    // логическая матрица наличия фишки
    private var pegs = [[Bool]]()
    
    private var selectedPeg: (row: Int, col: Int)?
    
    override func didMove(to view: SKView) {
            setupBoard()
            setupTimerLabel()
            applyTheme()
            applyThemeBack()
        }
    
    private func setupBoard() {
        cellSize = min(size.width / CGFloat(cols), size.height / CGFloat(rows))
        
        background = Array(repeating: Array(repeating: nil, count: cols), count: rows)
        board = Array(repeating: Array(repeating: nil, count: cols), count: rows)
        pegs = Array(repeating: Array(repeating: false, count: cols), count: rows)
        
        let startX = size.width/2 - CGFloat(cols)/2 * cellSize + cellSize/2
        let startY = size.height/2 - CGFloat(rows)/2 * cellSize + cellSize/2
        
        for r in 0..<rows {
            for c in 0..<cols {
                // создаём форму креста (Peg Solitaire)
                if (r < 2 || r > 4) && (c < 2 || c > 4) { continue }
                
                let pos = CGPoint(x: startX + CGFloat(c) * cellSize,
                                  y: startY + CGFloat(r) * cellSize)
                
                // 1) фон
                let bgColor: UIColor = (theme == .dark) ? .gray : .lightGray
                let bg = SKSpriteNode(color: bgColor,
                                      size: CGSize(width: cellSize*0.82, height: cellSize*0.82))
                bg.position = pos
                bg.zPosition = 0
                addChild(bg)
                background[r][c] = bg
                
                // 2) фишка (кроме центра)
                let pegColor: UIColor = (theme == .dark) ? .blue : .systemPink
                let peg = SKSpriteNode(color: pegColor,
                                       size: CGSize(width: cellSize*0.8, height: cellSize*0.8))
                peg.position = pos
                peg.zPosition = 1
                addChild(peg)
                
                board[r][c] = peg
                pegs[r][c] = true
            }
        }
        
        // центр пустой
        let center = rows / 2
        board[center][center]?.removeFromParent()
        board[center][center] = nil
        pegs[center][center] = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // если нажали кнопку рестарта
        if let node = self.atPoint(location) as? SKLabelNode,
           node.name == "restart_button" {
            restartGame()
            return
        }
        
        // если окно Game Over активно — другие нажатия игнорируем
        if childNode(withName: "gameover_dim") != nil {
            return
        }

        // обычная логика
        handleTouch(at: location)
    }

    private func restartGame() {
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = self.scaleMode
        
        let transition = SKTransition.fade(withDuration: 0.4)
        self.view?.presentScene(newScene, transition: transition)
    }

    private func handleTouch(at point: CGPoint) {
        guard let (row, col) = nodeAtPoint(point) else { return }
        
        if let selected = selectedPeg {
            if canMove(from: selected, to: (row, col)) {
                movePeg(from: selected, to: (row, col))
            }
            
            // снимаем подсветку
            if let selPeg = board[selected.row][selected.col] {
                selPeg.color = (theme == .dark) ? .blue : .systemPink
            }
            
            selectedPeg = nil
        } else {
            if pegs[row][col], let peg = board[row][col] {
                selectedPeg = (row, col)
                peg.color = .green
            }
        }
    }
    
    private func nodeAtPoint(_ point: CGPoint) -> (Int, Int)? {
        for r in 0..<rows {
            for c in 0..<cols {
                if background[r][c] == nil { continue }
                if let peg = board[r][c], peg.contains(point) {
                    return (r, c)
                }
                if let bg = background[r][c], bg.contains(point) {
                    return (r, c)
                }
            }
        }
        return nil
    }
    
    private func canMove(from: (Int, Int), to: (Int, Int)) -> Bool {
        let dr = to.0 - from.0
        let dc = to.1 - from.1
        
        if background[to.0][to.1] == nil { return false }
        
        // вертикально через одну
        if abs(dr) == 2 && dc == 0 {
            let mid = (from.0 + dr/2, from.1)
            return pegs[mid.0][mid.1] && !pegs[to.0][to.1]
        }
        
        // горизонтально через одну
        if abs(dc) == 2 && dr == 0 {
            let mid = (from.0, from.1 + dc/2)
            return pegs[mid.0][mid.1] && !pegs[to.0][to.1]
        }
        
        return false
    }
    
    private func movePeg(from: (Int, Int), to: (Int, Int)) {
        let mid = ((from.0 + to.0)/2, (from.1 + to.1)/2)
        
        // 1) удаляем среднюю фишку
        if let midPeg = board[mid.0][mid.1] {
            midPeg.removeFromParent()
            board[mid.0][mid.1] = nil
            pegs[mid.0][mid.1] = false
        }
        
        // 2) фишка, которая двигается
        guard let peg = board[from.0][from.1] else { return }
        
        // 3) целевая позиция — позиция фона
        guard let bgTarget = background[to.0][to.1] else { return }
        
        let moveAction = SKAction.move(to: bgTarget.position, duration: 0.18)
        peg.run(moveAction)
        
        // 4) обновляем логику
        board[from.0][from.1] = nil
        pegs[from.0][from.1] = false
        
        board[to.0][to.1] = peg
        pegs[to.0][to.1] = true
        
        peg.color = (theme == .dark) ? .blue : .systemPink
        peg.zPosition = 1
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
        for r in 0..<rows {
            for c in 0..<cols {
                if pegs[r][c] {
                    pegCount += 1
                }
            }
        }
        return pegCount == 1
    }
    
    private func anyMovesAvailable() -> Bool {
        for r in 0..<rows {
            for c in 0..<cols {
                
                if !pegs[r][c] { continue } // если фишки нет – пропускаем
                if background[r][c] == nil { continue }
                
                // возможные направления: вверх, вниз, влево, вправо
                let dirs = [
                    (-2, 0),
                    (2, 0),
                    (0, -2),
                    (0, 2)
                ]
                
                for dir in dirs {
                    let r2 = r + dir.0
                    let c2 = c + dir.1
                    let rMid = r + dir.0/2
                    let cMid = c + dir.1/2
                    
                    // проверяем выход за пределы
                    if r2 < 0 || r2 >= rows || c2 < 0 || c2 >= cols { continue }
                    if background[r2][c2] == nil { continue }
                    
                    // проверка: есть фишка → есть фишка для прыжка → пусто куда прыгать
                    if pegs[rMid][cMid] == true && pegs[r2][c2] == false {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    private func setupTimerLabel() {
            levelTimerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            levelTimerLabel.fontSize = 20
            levelTimerLabel.fontColor = .white
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
        lastElapsedTime = elapsed   // ← ВАЖНО

        levelTimerLabel.text = String(format: "Время: %.1f s", elapsed)
    }

    
    private func startLevelTimer(currentTime: TimeInterval) {
        levelStartTime = currentTime
        timerRunning = true
    }

    private func stopLevelTimer() {
            timerRunning = false
        }
    
    private func gameOver() {
        stopLevelTimer()
        showGameOverWindow()
    }

    private func showGameOverWindow() {
        // Затемняющий фон

        let dim = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.75), size: size)
        dim.position = CGPoint(x: size.width/2, y: size.height/2)
        dim.zPosition = 50
        dim.name = "gameover_dim"
        addChild(dim)
        
        // Белая панель (карточка)
        let panelSize = CGSize(width: size.width * 0.75, height: size.height * 0.36)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 28)
        panel.fillColor = .white
        panel.strokeColor = UIColor(white: 0.9, alpha: 1.0)
        panel.position = CGPoint(x: size.width/2, y: size.height/2)
        panel.zPosition = 51
        panel.name = "gameover_panel"
        addChild(panel)
        
        // GAME OVER текст
        let label = SKLabelNode(text: "GAME OVER")
        label.fontSize = 45
        label.fontColor = .black
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.fontName = "AvenirNext-Bold"
        label.position = CGPoint(x: 0, y: panelSize.height * 0.18)
        label.zPosition = 52
        panel.addChild(label)
        
        // Кнопка (фоном прямоугольник)
        let buttonWidth = panelSize.width * 0.62
        let buttonHeight: CGFloat = 56
        let button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 14)
        button.fillColor = UIColor(white: 0.87, alpha: 1.0)
        button.strokeColor = UIColor(white: 0.75, alpha: 1.0)
        button.zPosition = 52
        button.name = "restart_button_bg"
        button.position = CGPoint(x: 0, y: -panelSize.height * 0.20)
        panel.addChild(button)

        // Текст на кнопке
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
        // Затемняющий фон
        stopLevelTimer()

        if let start = levelStartTime {
            let elapsed = lastElapsedTime
            if bestTime == 0 || elapsed < bestTime {
                bestTime = elapsed
            }
        }

        let dim = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.75), size: size)
        dim.position = CGPoint(x: size.width/2, y: size.height/2)
        dim.zPosition = 50
        dim.name = "win_dim"
        addChild(dim)
        
        // Белая панель
        let panelSize = CGSize(width: size.width * 0.75, height: size.height * 0.36)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 28)
        panel.fillColor = .white
        panel.strokeColor = UIColor(white: 0.9, alpha: 1.0)
        panel.position = CGPoint(x: size.width/2, y: size.height/2)
        panel.zPosition = 51
        panel.name = "win_panel"
        addChild(panel)
        
        // WIN текст
        let label = SKLabelNode(text: "YOU WIN!")
        label.fontSize = 45
        label.fontColor = .black
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.fontName = "AvenirNext-Bold"
        label.position = CGPoint(x: 0, y: panelSize.height * 0.18)
        label.zPosition = 52
        panel.addChild(label)
        
        // Кнопка "Новая игра"
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

}

