import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var gameScene: GameScene!
    var user: UserData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let skView = self.view as? SKView {
            gameScene = GameScene(size: skView.bounds.size)
            gameScene.scaleMode = .aspectFill
            gameScene.user = user
            gameScene.boardShape = UserDatabase.shared.currentBoardShape
            
            skView.presentScene(gameScene)
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }

        // Кнопка настроек
        let buttonSize: CGFloat = 50
        let settingsButton = UIButton(type: .system)
        settingsButton.frame = CGRect(x: view.bounds.width - buttonSize - 20,
                                      y: view.bounds.height - buttonSize - 40,
                                      width: buttonSize,
                                      height: buttonSize)
        settingsButton.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        settingsButton.tintColor = .black
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        view.addSubview(settingsButton)
        
        // Кнопка возврата в меню
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 20, y: view.bounds.height - buttonSize - 40,
                                  width: buttonSize, height: buttonSize)
        backButton.setImage(UIImage(systemName: "arrowshape.turn.up.left.fill"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backToMenu), for: .touchUpInside)
        view.addSubview(backButton)
    }

    @objc private func openSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.user = user
        settingsVC.modalPresentationStyle = .overFullScreen
        
        // Сохраняем текущие темы
        let currentTheme = gameScene.theme
        let currentThemeBack = gameScene.themeBack
        
        settingsVC.onThemeChanged = { [weak self] newTheme in
            guard let self = self else { return }
            
            // Меняем только если тема действительно изменилась
            if currentTheme != newTheme {
                // Меняем цвета фишек в реальном времени
                self.gameScene.updatePegColors(newTheme: newTheme)
            }
        }
        
        settingsVC.onThemeChangedBack = { [weak self] newThemeBack in
            guard let self = self else { return }
            
            // Меняем только если фон действительно изменился
            if currentThemeBack != newThemeBack {
                // Меняем фон в реальном времени
                self.gameScene.updateSceneBackground(newThemeBack: newThemeBack)
            }
        }
        
        settingsVC.onBoardShapeChanged = { [weak self] newBoardShape in
            guard let self = self else { return }
            
            // Сохраняем выбор
            UserDatabase.shared.currentBoardShape = newBoardShape
            
            // Только для изменения формы доски перезапускаем игру
            if self.gameScene.boardShape != newBoardShape {
                self.restartGameWithNewBoard(boardShape: newBoardShape)
            }
        }
        
        settingsVC.onClose = { [weak self] in
            self?.backToMenu()
        }
        
        present(settingsVC, animated: true)
    }
    
    // Только для изменения формы доски
    private func restartGameWithNewBoard(boardShape: BoardShape) {
        guard let skView = self.view as? SKView else { return }
        
        let newScene = GameScene(size: skView.bounds.size)
        newScene.scaleMode = .aspectFill
        newScene.user = user
        newScene.boardShape = boardShape
        newScene.theme = gameScene.theme
        newScene.themeBack = gameScene.themeBack
        
        let transition = SKTransition.fade(withDuration: 0.3)
        skView.presentScene(newScene, transition: transition)
        
        gameScene = newScene
    }
    
    @objc private func backToMenu() {
        dismiss(animated: true) {
            let menuVC = MainMenuViewController(user: self.user)
            menuVC.modalPresentationStyle = .fullScreen
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(menuVC, animated: true)
            }
        }
    }

    override func loadView() {
        self.view = SKView(frame: UIScreen.main.bounds)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
