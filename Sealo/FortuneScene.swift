import SpriteKit

class FortuneScene: SKScene {

    weak var parentVC: UIViewController? // Контроллер, который показал SKView
    
    // MARK: - Данные пользователя
    var user: UserData!
    var onBalanceUpdate: ((Int) -> Void)?
    
    private var balance: Int {
        get { Int(user.balance) }
        set {
            let newVal = max(0, newValue)
            user.balance = Int64(newVal)
            onBalanceUpdate?(newVal)
            
            if newVal == 0 {
                showPopup("Баланс 0! Выход...", color: .red)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.exitToMainMenu()
                }
            }
        }
    }
    
    // MARK: - UI
    private var balanceLabel: SKLabelNode!
    private var spinButton: SKShapeNode!
    private var spinLabel: SKLabelNode!
    private var reel: SKNode!
    private var items: [SKLabelNode] = []
    private var isSpinning = false
    private var exitButton: SKShapeNode!
    private var exitLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.1, green: 0.12, blue: 0.14, alpha: 1)
        
        setupBalanceLabel()
        setupReel()
        setupSpinButton()
        setupExitButton()
    }
    
    // MARK: - Balance Label
    private func setupBalanceLabel() {
        balanceLabel = SKLabelNode(text: "")
        balanceLabel.fontName = "AvenirNext-Bold"
        balanceLabel.fontSize = 32
        balanceLabel.fontColor = .yellow
        balanceLabel.position = CGPoint(x: size.width/2, y: size.height - 80)
        addChild(balanceLabel)
        updateBalanceLabel()
    }
    
    private func updateBalanceLabel() {
        balanceLabel.text = "Баланс: \(balance) 🪙"
    }
    
    // MARK: - Spin Button
    private func setupSpinButton() {
        spinButton = SKShapeNode(rectOf: CGSize(width: 250, height: 70), cornerRadius: 15)
        spinButton.fillColor = .systemGreen
        spinButton.strokeColor = .clear
        spinButton.position = CGPoint(x: size.width/2, y: 120)
        spinButton.name = "spinButton"
        addChild(spinButton)
        
        spinLabel = SKLabelNode(text: "КРУТИТЬ 🎰")
        spinLabel.fontName = "AvenirNext-Bold"
        spinLabel.fontSize = 26
        spinLabel.fontColor = .white
        spinLabel.verticalAlignmentMode = .center
        spinLabel.position = .zero
        spinLabel.name = "spinButton"
        spinButton.addChild(spinLabel)
    }
    
    // MARK: - Reel
    private func setupReel() {
        reel = SKNode()
        reel.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(reel)
        
        let symbols = ["🪙", "💎", "⭐️", "🔥", "💰"]
        for i in 0..<symbols.count {
            let label = SKLabelNode(text: symbols[i])
            label.fontName = "AvenirNext-Bold"
            label.fontSize = 60
            label.position = CGPoint(x: 0, y: CGFloat(i - 2) * 80)
            reel.addChild(label)
            items.append(label)
        }
    }
    
    // MARK: - Exit Button
    private func setupExitButton() {
        exitButton = SKShapeNode(rectOf: CGSize(width: 100, height: 50), cornerRadius: 12)
        exitButton.fillColor = .systemRed
        exitButton.strokeColor = .clear
        exitButton.position = CGPoint(x: size.width - 80, y: size.height - 50)
        exitButton.name = "exitButton"
        addChild(exitButton)
        
        exitLabel = SKLabelNode(text: "ВЫЙТИ")
        exitLabel.fontName = "AvenirNext-Bold"
        exitLabel.fontSize = 18
        exitLabel.fontColor = .white
        exitLabel.verticalAlignmentMode = .center
        exitLabel.position = .zero
        exitLabel.name = "exitButton"
        exitButton.addChild(exitLabel)
    }
    
    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node.name == "spinButton" {
                if !isSpinning { startSpin() }
                return
            } else if node.name == "exitButton" {
                exitToMainMenu()
                return
            }
        }
    }
    
    // MARK: - Exit to Main Menu
    private func exitToMainMenu() {
        // Сохраняем баланс
        UserDatabase.shared.save()
        
        // Закрываем SKView и возвращаемся в MainMenuViewController
        parentVC?.dismiss(animated: true)
    }
    
    // MARK: - Spin Logic
    private func startSpin() {
        guard !isSpinning else { return }
        guard balance >= 10 else {
            showPopup("Недостаточно монет!", color: .red)
            return
        }
        
        isSpinning = true
        balance -= 10
        updateBalanceLabel()
        
        let isWin = Bool.random()
        let delta = Int.random(in: 10...80)
        let result = isWin ? delta : -delta
        
        let spinCount = 20
        let spinAction = SKAction.repeat(SKAction.sequence([
            SKAction.run { [weak self] in self?.shiftReelDown() },
            SKAction.wait(forDuration: 0.05)
        ]), count: spinCount)
        
        let finish = SKAction.run { [weak self] in
            self?.finishSpin(delta: result)
        }
        
        reel.run(SKAction.sequence([spinAction, finish]))
    }
    
    private func shiftReelDown() {
        guard !items.isEmpty else { return }
        let step: CGFloat = 80
        for label in items { label.position.y -= step }
        if let first = items.first, first.position.y < -step*2 {
            first.position.y += step * CGFloat(items.count)
            items.append(first)
            items.removeFirst()
        }
    }
    
    private func finishSpin(delta: Int) {
        for (i, label) in items.enumerated() {
            label.position.y = CGFloat(i - 2) * 80
        }
        
        balance += delta
        updateBalanceLabel()
        
        if delta > 0 {
            showPopup("Вы выиграли +\(delta) 🪙", color: .green)
        } else {
            showPopup("Вы потеряли \(abs(delta)) 🪙", color: .red)
        }
        
        isSpinning = false
        UserDatabase.shared.save()
    }
    
    // MARK: - Popup
    private func showPopup(_ text: String, color: UIColor) {
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 30
        label.fontColor = color
        label.alpha = 0
        label.position = CGPoint(x: size.width/2, y: size.height/2 + 180)
        label.zPosition = 30
        addChild(label)
        
        label.run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.3),
                SKAction.moveBy(x: 0, y: 25, duration: 0.8)
            ]),
            SKAction.wait(forDuration: 0.7),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))
    }
}


