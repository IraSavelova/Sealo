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
            skView.presentScene(gameScene)
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }

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
    }

    @objc private func openSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.user = user
        settingsVC.modalPresentationStyle = .overFullScreen
        
        settingsVC.onThemeChanged = { [weak self] newTheme in
            self?.gameScene.theme = newTheme
        }
        
        settingsVC.onThemeChangedBack = { [weak self] newThemeBack in
            self?.gameScene.themeBack = newThemeBack
        }
        
        present(settingsVC, animated: true)
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

