import UIKit

final class NewHabitCreationViewController: UIViewController {
    
    // MARK: - UI Elements
    private var tableViewTopConstraint: NSLayoutConstraint?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите название трекера"
        tf.backgroundColor = UIColor(resource: .ypBackgroundGray)
        tf.layer.cornerRadius = 16
        tf.layer.masksToBounds = true
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor(resource: .ypRed)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.isScrollEnabled = false
        tv.backgroundColor = UIColor(resource: .ypBackgroundGray)
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
        btn.backgroundColor = UIColor(resource: .ypGray3)
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Data
    
    var selectedSchedule: TrackerSchedule? = nil
    var onCreate: ((Tracker) -> Void)?
    
    private let tableItems = ["Категория", "Расписание"]
    private let cellIdentifier = "cell"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
        setupTableView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(errorLabel)
        view.addSubview(tableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24)
        
        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Поле для названия
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            // Ошибка под текстовым полем
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.heightAnchor.constraint(equalToConstant: 22),
            
            // Таблица
            tableViewTopConstraint!,
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            // Кнопки
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalToConstant: 166),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func setupTableView() {
        tableView.layer.cornerRadius = 16
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    private func updateCreateButtonState() {
        guard let text = nameTextField.text else { return }
        
        let isNameValid = !text.trimmingCharacters(in: .whitespaces).isEmpty && text.count <= 38
        
        let isScheduleSelected = (selectedSchedule?.days.isEmpty == false)
        
        let isValid = isNameValid && isScheduleSelected
        
        UIView.animate(withDuration: 0.25) {
            if isValid {
                self.createButton.backgroundColor = UIColor(resource: .ypBlack)
                self.createButton.setTitleColor(.white, for: .normal)
                self.createButton.isEnabled = true
            } else {
                self.createButton.backgroundColor = UIColor(resource: .ypGray3)
                self.createButton.setTitleColor(.white, for: .normal)
                self.createButton.isEnabled = false
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.count > 38 {
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
        
        tableViewTopConstraint?.constant = errorLabel.isHidden ? 24 : 62
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        updateCreateButtonState()
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createTapped() {
        var name = nameTextField.text ?? ""
        
        if name.isEmpty {
            name = "Без названия"
        } else if name.count > 38 {
            let index = name.index(name.startIndex, offsetBy: 38)
            name = String(name[..<index])
        }
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: .systemBlue, // дефолт
            emoji: "✅",         // дефолт
            schedule: selectedSchedule
        )
        
        onCreate?(tracker)
        dismiss(animated: true)
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK: - TableView Delegate & DataSource

extension NewHabitCreationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = tableItems[indexPath.row]
        config.textProperties.font = UIFont.systemFont(ofSize: 17)
        
        if indexPath.row == 1, let selectedSchedule = selectedSchedule {
            let daysText = selectedSchedule.daysText
            config.secondaryText = daysText
            config.secondaryTextProperties.font = UIFont.systemFont(ofSize: 15)
            config.secondaryTextProperties.color = .gray
        }
                
        config.textProperties.font = UIFont.systemFont(ofSize: 17)
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(resource: .ypBackgroundGray)
        
        tableView.separatorStyle = .none
        
        cell.contentView.subviews
            .filter { $0.tag == 999 }
            .forEach { $0.removeFromSuperview() }
        
        if indexPath.row == 0 {
            let separator = UIView()
            separator.backgroundColor = UIColor.systemGray3
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.tag = 999
            cell.contentView.addSubview(separator)
            
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController()
            scheduleVC.modalPresentationStyle = .automatic
            scheduleVC.selectedDays = selectedSchedule?.days ?? []
            scheduleVC.onSave = { [weak self] selectedDays in
                guard let self = self else { return }
                
                if !selectedDays.isEmpty {
                    self.selectedSchedule = TrackerSchedule(days: selectedDays)
                } else {
                    self.selectedSchedule = nil
                }
                
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.updateCreateButtonState()
            }
            present(scheduleVC, animated: true)
        } else {
            // переход к экрану категории
        }
    }
}

