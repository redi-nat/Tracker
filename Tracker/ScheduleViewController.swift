import UIKit

final class ScheduleViewController: UIViewController {
    
    private let weekdays: [String] = [
        "Понедельник", "Вторник", "Среда",
        "Четверг", "Пятница", "Суббота", "Воскресенье"
    ]
    
    var selectedDays: [TrackerSchedule.Weekday] = []
    var onSave: (([TrackerSchedule.Weekday]) -> Void)?
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = UIColor(named: "ypBackgroundGray")
        tv.layer.cornerRadius = 16
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        return tv
    }()
    
    private let doneButton: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("Готово", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = .black
            btn.layer.cornerRadius = 16
            btn.translatesAutoresizingMaskIntoConstraints = false
            return btn
        }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupTableView()
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Кнопка Готово
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Таблица
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(weekdays.count) * 75)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @objc private func doneTapped() {
            onSave?(selectedDays)
            dismiss(animated: true)
        }
}

// MARK: - UITableViewDataSource & Delegate

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekdays.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "ypBackgroundGray")
        cell.textLabel?.text = weekdays[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        
        let weekdayEnum = TrackerSchedule.Weekday(rawValue: indexPath.row + 1)!
        
        let switchView = UISwitch()
        switchView.isOn = selectedDays.contains(weekdayEnum)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        cell.accessoryView = switchView
        return cell
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let weekdayEnum = TrackerSchedule.Weekday(rawValue: sender.tag + 1)!
        if sender.isOn {
            selectedDays.append(weekdayEnum)
        } else {
            selectedDays.removeAll { $0 == weekdayEnum }
        }
    }
}
