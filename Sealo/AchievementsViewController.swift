import UIKit
import CoreData

final class LeaderboardViewController: UIViewController {

    private let tableView = UITableView()
    private var users: [UserData] = []
    private let backButton = UIButton(type: .system) // Добавлена кнопка назад

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupBackButton() // Настраиваем кнопку назад
        setupTableView()
        loadUsers()
    }

    // MARK: - Data

    private func loadUsers() {
        let request: NSFetchRequest<UserData> = UserData.fetchRequest()

        if let result = try? UserDatabase.shared.context.fetch(request) {
            users = result.sorted {
                let t1 = $0.bestLevelTime == 0 ? .greatestFiniteMagnitude : $0.bestLevelTime
                let t2 = $1.bestLevelTime == 0 ? .greatestFiniteMagnitude : $1.bestLevelTime
                return t1 < t2
            }
        }

        tableView.reloadData()
    }

    // MARK: - UI

    private func setupBackButton() {
        // Кнопка назад
        backButton.setTitle("← Назад", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        // Заголовок
        let titleLabel = UILabel()
        titleLabel.text = "Рейтинг игроков"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(LeaderboardCell.self, forCellReuseIdentifier: "LeaderboardCell")
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension LeaderboardViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "LeaderboardCell",
            for: indexPath
        ) as! LeaderboardCell
        
        let user = users[indexPath.row]
        let place = indexPath.row + 1

        cell.configure(
            place: place,
            username: user.username ?? "Без имени",
            bestTime: user.bestLevelTime
        )
        return cell
    }
}

// MARK: - Custom Cell (В ЭТОМ ЖЕ ФАЙЛЕ)

final class LeaderboardCell: UITableViewCell {

    private let card = UIView()
    private let placeLabel = UILabel()
    private let nameLabel = UILabel()
    private let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false

        placeLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.font = .systemFont(ofSize: 16)
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 16, weight: .medium)

        let stack = UIStackView(arrangedSubviews: [
            placeLabel,
            nameLabel,
            timeLabel
        ])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(card)
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
    }

    func configure(place: Int, username: String, bestTime: TimeInterval) {
        placeLabel.text = "#\(place)"
        nameLabel.text = username

        if bestTime == 0 {
            timeLabel.text = "0.0 s"
        } else {
            timeLabel.text = String(format: "%.1f s", bestTime)
        }

        // Подсветка топ-3
        switch place {
        case 1:
            card.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.25)
        case 2:
            card.backgroundColor = UIColor.systemGray.withAlphaComponent(0.25)
        case 3:
            card.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.25)
        default:
            card.backgroundColor = .secondarySystemBackground
        }
    }
}
