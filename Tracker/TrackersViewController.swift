import UIKit

final class TrackersViewController: UIViewController {

    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private var selectedDate = Date()
    private var displayedCategories: [TrackerCategory] = []
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(systemName: "star"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = UIColor.label
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return view
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupDatePicker()
        setupInitialData()
        updateTrackers(for: selectedDate)

        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        emptyStateView.isHidden = true
    }

    // MARK: - DatePicker

    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        updateTrackers(for: selectedDate)
    }

    // MARK: - CollectionView

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
        let hasFilteredTrackers = displayedCategories.contains { !$0.trackers.isEmpty }
        emptyStateView.isHidden = hasFilteredTrackers
        collectionView.isHidden = !hasFilteredTrackers
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

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        displayedCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayedCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tracker = categories[indexPath.section].trackers[indexPath.item]
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
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CategoryHeaderView.identifier,
            for: indexPath
        ) as! CategoryHeaderView
        
        header.titleLabel.text = categories[indexPath.section].title
        return header
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }

    // MARK: - Layout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 16 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 9 }
}

final class CategoryHeaderView: UICollectionReusableView {
    
    static let identifier = "CategoryHeaderView"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        ])
    }
}
