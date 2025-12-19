
import UIKit

// MARK: - Структуры
enum ShopItemType {
    case pegColor
    case backgroundColor
}

struct ShopItem {
    let type: ShopItemType
    let title: String
    let price: Int
    let color: UIColor
    var isPurchased: Bool
}

// MARK: - Shop
class ShopViewController: UIViewController {

    private let user: UserData

    private var balanceLabel = UILabel()
    private var collectionView: UICollectionView!

    private var items: [ShopItem] = []

    init(user: UserData) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadItems()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        // Панель
        let panel = UIView()
        panel.backgroundColor = .white
        panel.layer.cornerRadius = 25
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)
        NSLayoutConstraint.activate([
            panel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            panel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            panel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            panel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7)
        ])

        // Крестик закрытия
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = .boldSystemFont(ofSize: 28)
        closeButton.setTitleColor(.darkGray, for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: panel.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Баланс
        balanceLabel.font = .boldSystemFont(ofSize: 24)
        balanceLabel.textColor = .systemYellow
        balanceLabel.textAlignment = .center
        balanceLabel.text = "Баланс: \(user.balance) 🪙"
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(balanceLabel)
        NSLayoutConstraint.activate([
            balanceLabel.topAnchor.constraint(equalTo: panel.topAnchor, constant: 70),
            balanceLabel.centerXAnchor.constraint(equalTo: panel.centerXAnchor)
        ])

        // CollectionView для карточек
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = CGSize(width: (view.bounds.width * 0.85 - 48)/2, height: 140)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ShopItemCell.self, forCellWithReuseIdentifier: "ShopItemCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        panel.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Load Items
    private func loadItems() {
        // Получаем массивы из Transformable или пустые, если nil
        let ownedPegColors = (user.ownedPegColors as? [String]) ?? []
        let ownedBackgroundColors = (user.ownedBackgroundColors as? [String]) ?? []

        items = [
            ShopItem(type: .pegColor, title: "Красные фишки", price: 100, color: .systemRed, isPurchased: ownedPegColors.contains("red")),
            ShopItem(type: .pegColor, title: "Зелёные фишки", price: 100, color: .systemGreen, isPurchased: ownedPegColors.contains("green")),
            ShopItem(type: .backgroundColor, title: "Синий фон", price: 150, color: .systemBlue, isPurchased: ownedBackgroundColors.contains("blue")),
            ShopItem(type: .backgroundColor, title: "Жёлтый фон", price: 150, color: .systemYellow, isPurchased: ownedBackgroundColors.contains("yellow"))
        ]

        collectionView.reloadData()
    }


    // MARK: - Close
    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func updateBalanceLabel() {
        balanceLabel.text = "Баланс: \(user.balance) 🪙"
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ShopViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopItemCell", for: indexPath) as? ShopItemCell else { return UICollectionViewCell() }
        let item = items[indexPath.item]
        cell.configure(with: item)
        cell.onBuyTapped = { [weak self] in
            self?.buy(itemIndex: indexPath.item)
        }
        return cell
    }

    private func buy(itemIndex: Int) {
        var item = items[itemIndex]

        guard !item.isPurchased else { return }

        if user.balance >= item.price {
            user.balance -= Int64(item.price)
            switch item.type {
            case .pegColor:
                var ownedPegColors = (user.ownedPegColors as? [String]) ?? []
                if item.color == .systemRed, !ownedPegColors.contains("red") {
                    ownedPegColors.append("red")
                }
                if item.color == .systemGreen, !ownedPegColors.contains("green") {
                    ownedPegColors.append("green")
                }
                user.ownedPegColors = ownedPegColors as NSObject
            case .backgroundColor:
                var ownedBackgroundColors = (user.ownedBackgroundColors as? [String]) ?? []
                if item.color == .systemBlue, !ownedBackgroundColors.contains("blue") {
                    ownedBackgroundColors.append("blue")
                }
                if item.color == .systemYellow, !ownedBackgroundColors.contains("yellow") {
                    ownedBackgroundColors.append("yellow")
                }
                user.ownedBackgroundColors = ownedBackgroundColors as NSObject
            }

            item.isPurchased = true
            items[itemIndex] = item

            UserDatabase.shared.save()
            collectionView.reloadItems(at: [IndexPath(item: itemIndex, section: 0)])
            updateBalanceLabel()
        } else {
            // Недостаточно монет
            let alert = UIAlertController(title: "Недостаточно монет", message: "Заработайте больше монет, чтобы купить этот предмет", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - ShopItemCell
class ShopItemCell: UICollectionViewCell {

    private let colorView = UIView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let buyButton = UIButton(type: .system)

    var onBuyTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.layer.shadowRadius = 4

        colorView.layer.cornerRadius = 12
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 60),
            colorView.heightAnchor.constraint(equalToConstant: 60)
        ])

        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])

        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textAlignment = .center
        priceLabel.textColor = .darkGray
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])

        buyButton.setTitle("Купить", for: .normal)
        buyButton.titleLabel?.font = .boldSystemFont(ofSize: 12)
        buyButton.backgroundColor = .systemBlue
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.layer.cornerRadius = 12
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        buyButton.addTarget(self, action: #selector(buyTapped), for: .touchUpInside)
        contentView.addSubview(buyButton)
        NSLayoutConstraint.activate([
            buyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            buyButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buyButton.widthAnchor.constraint(equalToConstant: 68),
            buyButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    func configure(with item: ShopItem) {
        colorView.backgroundColor = item.color
        titleLabel.text = item.title
        priceLabel.text = "\(item.price) 🪙"
        buyButton.isEnabled = !item.isPurchased
        buyButton.backgroundColor = item.isPurchased ? .gray : .systemBlue
        buyButton.setTitle(item.isPurchased ? "Куплено" : "Купить", for: .normal)
    }

    @objc private func buyTapped() {
        onBuyTapped?()
    }
}
