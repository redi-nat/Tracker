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

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let emojis = ["😀", "🥳", "😎", "❤️", "🔥", "🌿", "🐱", "🐶", "🍎", "🍔", "🎧", "✈️", "🎯", "📚", "💡", "🎵", "🚀", "🍕"]

    private let colors: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue,
        .systemTeal, .systemIndigo, .systemPurple, .systemPink, .brown,
        .gray, .black, .magenta, .systemCyan, .systemMint, .systemBrown,
        .systemGray2, .systemGray3
    ]

    private var selectedEmoji: String?
    private var selectedColor: UIColor?

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
        setupCollections()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Setup UI
    private func setupUI() {

        let scrollView = UIScrollView()
        let contentView = UIView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // contentView
        contentView.addSubview(titleLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(errorLabel)
        contentView.addSubview(tableView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(cancelButton)
        contentView.addSubview(createButton)

        // scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // UI
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24)
        NSLayoutConstraint.activate([
            
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -22),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Поле для названия
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            // Ошибка под текстовым полем
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorLabel.heightAnchor.constraint(equalToConstant: 22),
            
            // Таблица
            tableViewTopConstraint!,
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            // Emoji
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 156),
            
            // Colors
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 32),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 180),
            
            // Кнопки
            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 32),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 32),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalToConstant: 166),
            createButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
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

    private func setupCollections() {
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")

        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
    }

    private func updateCreateButtonState() {
        guard let text = nameTextField.text else { return }
        let isNameValid = !text.trimmingCharacters(in: .whitespaces).isEmpty && text.count <= 38
        let isScheduleSelected = (selectedSchedule?.days.isEmpty == false)
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isValid = isNameValid && isScheduleSelected && isEmojiSelected && isColorSelected

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
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
        updateCreateButtonState()
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func createTapped() {
        var name = nameTextField.text ?? ""
        if name.isEmpty { name = "Без названия" }
        else if name.count > 38 {
            let index = name.index(name.startIndex, offsetBy: 38)
            name = String(name[..<index])
        }
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: selectedColor ?? .black,
            emoji: selectedEmoji ?? "😀",
            schedule: selectedSchedule
        )
        onCreate?(tracker)
        dismiss(animated: true)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - TableView
extension NewHabitCreationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    final class EmojiCell: UICollectionViewCell {
        static let reuseId = "EmojiCell"
        private let label = UILabel()
        override init(frame: CGRect) {
            super.init(frame: frame)
            label.font = UIFont.systemFont(ofSize: 32)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
            contentView.layer.cornerRadius = 26
        }
        required init?(coder: NSCoder) { fatalError() }
        func configure(with emoji: String, selected: Bool) {
            label.text = emoji
            contentView.backgroundColor = selected ? UIColor(resource: .ypBackgroundGray) : .clear
        }
    }
    
    final class ColorCell: UICollectionViewCell {
        static let reuseId = "ColorCell"
        private let colorView = UIView()
        override init(frame: CGRect) {
            super.init(frame: frame)
            colorView.layer.cornerRadius = 8
            colorView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(colorView)
            NSLayoutConstraint.activate([
                colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                colorView.widthAnchor.constraint(equalToConstant: 40),
                colorView.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        required init?(coder: NSCoder) { fatalError() }
        func configure(with color: UIColor, selected: Bool) {
            colorView.backgroundColor = color
            contentView.layer.borderWidth = selected ? 3 : 0
            contentView.layer.borderColor = selected ? color.cgColor : nil
        }
    }
}

    extension NewHabitCreationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if collectionView == emojiCollectionView {
                return emojis.count
            } else {
                return colors.count
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if collectionView == emojiCollectionView {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseId, for: indexPath) as! EmojiCell
                let emoji = emojis[indexPath.item]
                cell.configure(with: emoji, selected: emoji == selectedEmoji)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseId, for: indexPath) as! ColorCell
                let color = colors[indexPath.item]
                cell.configure(with: color, selected: color == selectedColor)
                return cell
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if collectionView == emojiCollectionView {
                selectedEmoji = emojis[indexPath.item]
                collectionView.reloadData()
            } else {
                selectedColor = colors[indexPath.item]
                collectionView.reloadData()
            }
            updateCreateButtonState()
        }
    }
    
    extension NewHabitCreationViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let itemsPerRow: CGFloat = 6
            let sectionInsets: CGFloat = 18 * 2
            let interItemSpacing: CGFloat = 8 * (itemsPerRow - 1)
            let availableWidth = view.bounds.width - sectionInsets - interItemSpacing
            let itemWidth = floor(availableWidth / itemsPerRow)
            return CGSize(width: itemWidth, height: itemWidth)
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 8
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
    }

