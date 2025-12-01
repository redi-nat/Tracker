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
        tv.backgroundColor = UIColor(resource: .ypBackgroundGray)
        tv.layer.cornerRadius = 16
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        return tv
    }()
    
    private let doneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Готово", for: .normal)
        btn.setTitleColor(UIColor(resource: .ypMainBackground), for: .normal)
        btn.backgroundColor = UIColor(resource: .ypBlack)
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
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            
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
        tableView.separatorColor = UIColor(resource: .ypGray3)
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
        cell.backgroundColor = UIColor(resource: .ypBackgroundGray)
        cell.textLabel?.text = weekdays[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textAlignment = .left
        
        guard let weekdayEnum = TrackerSchedule.Weekday(rawValue: indexPath.row + 1) else {
            return cell
        }

        let switchView = UISwitch()
        switchView.isOn = selectedDays.contains(weekdayEnum)
        switchView.onTintColor = .systemBlue
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        cell.accessoryView = switchView
        
        let accessoryWidth = cell.accessoryView?.frame.width ?? 0
        cell.textLabel?.frame = CGRect(
            x: 16,
            y: 0,
            width: cell.contentView.frame.width - 32 - accessoryWidth,
            height: cell.contentView.frame.height
        )
        
        return cell
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    @objc private func switchChanged(_ sender: UISwitch) {
        guard let weekdayEnum = TrackerSchedule.Weekday(rawValue: sender.tag + 1) else { return }
        if sender.isOn {
            selectedDays.append(weekdayEnum)
        } else {
            selectedDays.removeAll { $0 == weekdayEnum }
        }
    }
}
