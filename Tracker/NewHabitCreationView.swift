import UIKit

final class NewHabitCreationViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите название трекера"
        tf.backgroundColor = UIColor(named: "ypBackgroundGray")
        tf.layer.cornerRadius = 16
        tf.layer.masksToBounds = true
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.isScrollEnabled = false
        tv.backgroundColor = UIColor(named: "ypBackgroundGray")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Отменить", for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemRed.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let createButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Создать", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(named: "ypGray3")
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    
    // MARK: - Data
    
    var selectedSchedule: TrackerSchedule? = nil
    var onCreate: ((Tracker) -> Void)?
    
    private let tableItems = ["Категория", "Расписание"]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
        setupTableView()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(tableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Поле для названия
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            // Кнопка "Отменить"
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            // Кнопка "Создать"
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalToConstant: 166),
            createButton.heightAnchor.constraint(equalToConstant: 60),

            // Таблица
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
        ])
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createTapped() {
        // создание трекера
    }
}

// MARK: - TableView Delegate & DataSource

extension NewHabitCreationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableItems.count
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 75
        }
    
    func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = tableItems[indexPath.row]
            config.textProperties.font = UIFont.systemFont(ofSize: 17)
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = UIColor(named: "ypBackgroundGray")
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController()
            scheduleVC.modalPresentationStyle = .automatic
            present(scheduleVC, animated: true)
        } else {
            // переход к экрану Категория
        }
    }
}
