import UIKit

// MARK: - TrackersViewController

final class TrackersViewController: UIViewController {

    // MARK: - Properties

    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var selectedDate = Date()
    private var displayedCategories: [TrackerCategory] = []

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let datePicker: UIDatePicker = {
            let picker = UIDatePicker()
            picker.datePickerMode = .date
            picker.preferredDatePickerStyle = .compact
            picker.translatesAutoresizingMaskIntoConstraints = false
            picker.locale = Locale(identifier: "ru_RU")
            return picker
        }()

    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Поиск"
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(resource: .ypGray2)
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 8, y: 0, width: 20, height: 20)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 20))
        leftView.addSubview(imageView)
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        return textField
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        return cv
    }()

    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView (image: UIImage(resource: .errorStar))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0
        return imageView
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(resource: .addTracker)
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 21
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupInitialData()
        updateTrackers(for: selectedDate)
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(searchTextField)
        view.addSubview(collectionView)
        view.addSubview(datePicker)
        view.addSubview(addButton)
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)

        setupDatePicker()
        setupAddButton()
        setupEmptyState()
        setupConstraints()
    }

    private func setupDatePicker() {
            NSLayoutConstraint.activate([
                datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 49),
                datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                datePicker.widthAnchor.constraint(equalToConstant: 100),
                datePicker.heightAnchor.constraint(equalToConstant: 34)
            ])
            
            updateDatePickerText()
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        }
    
    private func updateDatePickerText() {
            if let textField = datePicker.subviews.first?.subviews.first(where: { $0 is UITextField }) as? UITextField {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yy"
                textField.text = formatter.string(from: datePicker.date)
                textField.font = UIFont.systemFont(ofSize: 17)
            }
        }

    private func setupAddButton() {
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            addButton.widthAnchor.constraint(equalToConstant: 42),
            addButton.heightAnchor.constraint(equalToConstant: 42)
        ])
        
        addButton.addTarget(self, action: #selector(addTrackerButtonTapped(_:)), for: .touchUpInside)
    }

    private func setupEmptyState() {
        NSLayoutConstraint.activate([
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        emptyStateImageView.isUserInteractionEnabled = false
        emptyStateLabel.isUserInteractionEnabled = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),

            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - CollectionView Setup

    private func setupCollectionView() {
        collectionView.register(TrackerCollectionViewCell.self,
                                forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(CategoryHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CategoryHeaderView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    // MARK: - Data

    private func setupInitialData() {
        let schedule = TrackerSchedule(days: [.monday, .wednesday, .friday])
        
        let tracker1 = Tracker(id: UUID(), name: "Утренняя зарядка", color: .systemBlue, emoji: "💪", schedule: schedule)
        let tracker2 = Tracker(id: UUID(), name: "Прогулка с собакой", color: .systemGreen, emoji: "🐕", schedule: schedule)
        let tracker3 = Tracker(id: UUID(), name: "Медитация", color: .systemPurple, emoji: "🧘", schedule: schedule)
        let tracker4 = Tracker(id: UUID(), name: "Выпить таблетки", color: .systemRed, emoji: "💊", schedule: schedule)
         
        let health = TrackerCategory(title: "Здоровье", trackers: [tracker1, tracker2, tracker4])
        let mindfulness = TrackerCategory(title: "Развитие", trackers: [tracker3])
        
        categories = [health, mindfulness]
    }

    private func updateTrackers(for date: Date) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let mappedWeekday = weekday == 1 ? 7 : weekday - 1
        
        displayedCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                guard let schedule = tracker.schedule else { return true }
                return schedule.days.contains { $0.rawValue == mappedWeekday }
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        collectionView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        let hasTrackers = displayedCategories.contains { !$0.trackers.isEmpty }
        UIView.animate(withDuration: 0.25) {
            self.emptyStateImageView.alpha = hasTrackers ? 0 : 1
            self.emptyStateLabel.alpha = hasTrackers ? 0 : 1
            self.collectionView.alpha = hasTrackers ? 1 : 0
        }
    }

    // MARK: - Actions

    @objc private func dateChanged(_ sender: UIDatePicker) {
            selectedDate = sender.date
            updateDatePickerText()
            updateTrackers(for: selectedDate)
        }

    @objc private func addTrackerButtonTapped(_ sender: UIButton) {
        let habitVC = NewHabitCreationViewController()
        
        habitVC.onCreate = { [weak self] tracker in
            guard let self = self else { return }
            
            if let index = self.categories.firstIndex(where: { $0.title == "Без категории" }) {
                var category = self.categories[index]
                var trackers = category.trackers
                trackers.append(tracker)
                let newCategory = TrackerCategory(title: category.title, trackers: trackers)
                self.categories[index] = newCategory
            } else {
                let newCategory = TrackerCategory(title: "Без категории", trackers: [tracker])
                self.categories.append(newCategory)
            }

            self.updateTrackers(for: self.selectedDate)
        }
        
        let nav = UINavigationController(rootViewController: habitVC)
        present(nav, animated: true)
    }


    // MARK: - Tracker Completion

    func completeTracker(_ tracker: Tracker, for date: Date) {
        let record = TrackerRecord(trackerId: tracker.id, date: date)
        completedTrackers.append(record)
    }
    
    func uncompleteTracker(_ tracker: Tracker, for date: Date) {
        completedTrackers.removeAll {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        completedTrackers.contains {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        displayedCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayedCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tracker = displayedCategories[indexPath.section].trackers[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else { return UICollectionViewCell() }

        let isCompleted = isTrackerCompleted(tracker, on: selectedDate)
        let count = completedTrackers.filter { $0.trackerId == tracker.id }.count
        let isFuture = Calendar.current.compare(selectedDate, to: Date(), toGranularity: .day) == .orderedDescending

        cell.configure(with: tracker, count: count, isCompleted: isCompleted, isFuture: isFuture)

        cell.onToggle = { [weak self] in
            guard let self else { return }
            if isFuture { return }
            if isCompleted {
                self.uncompleteTracker(tracker, for: self.selectedDate)
            } else {
                self.completeTracker(tracker, for: self.selectedDate)
            }
            self.collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }

    // MARK: - Section Header

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CategoryHeaderView.identifier,
            for: indexPath
        ) as? CategoryHeaderView else {
            assertionFailure("Failed to dequeue CategoryHeaderView")
            return UICollectionReusableView()
        }

        header.configure(with: displayedCategories[indexPath.section].title)
        return header
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 18)
    }

    // MARK: - Layout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 2
        let sectionInsets = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
        let interItemSpacing: CGFloat = 9
        

        let totalSpacing = sectionInsets.left
            + sectionInsets.right
            + interItemSpacing * (itemsPerRow - 1)
        
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / itemsPerRow)
        let itemHeight: CGFloat = 148
        
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 9 }
}

// MARK: - CategoryHeaderView

final class CategoryHeaderView: UICollectionReusableView {
    
    static let identifier = "CategoryHeaderView"
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -0)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with text: String) {
        titleLabel.text = text
    }
}
