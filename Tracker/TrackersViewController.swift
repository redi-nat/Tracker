import UIKit

// MARK: - TrackersViewController

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    
    private var categories: [TrackerCategory] = []
    private var selectedDate = Calendar.current.startOfDay(for: Date())
    private var displayedCategories: [TrackerCategory] = []
    private var currentFilter: TrackerFilter = .allTrackers
    
    private var trackerStore: TrackerStoreProtocol
    private var recordStore: TrackerRecordStoreProtocol
    private var categoryStore: TrackerCategoryStoreProtocol
        
        init(trackerStore: TrackerStoreProtocol = TrackerStore.shared,
             recordStore: TrackerRecordStoreProtocol = TrackerRecordStore.shared,
             categoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore.shared) {
            
            self.trackerStore = trackerStore
            self.recordStore = recordStore
            self.categoryStore = categoryStore
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers.title", comment: "Заголовок экрана Трекеры")
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.backgroundColor = UIColor(resource: .ypDatePicker)
        picker.overrideUserInterfaceStyle = .light
        picker.layer.cornerRadius = 8
        picker.layer.masksToBounds = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.locale = Locale(identifier: "ru_RU")
        return picker
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("search.placeholder", comment: "Плейсхолдер для поиска")
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(resource: .ypGray2)
        textField.textColor = UIColor(resource: .ypGrayText)
        
        let placeholderColor = UIColor(resource: .ypGrayText)
        
        if let placeholderText = textField.placeholder {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [.foregroundColor: placeholderColor]
            )
        }
        
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = UIColor(resource: .ypGrayText)
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
        cv.backgroundColor = UIColor(resource: .ypMainBackground)
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
        label.text = NSLocalizedString("empty.trackers.title", comment: "Текст заглушки для пустого экрана трекеров")
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
        button.tintColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 21
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters.button", comment: "Название кнопки Фильтры"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlue)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AnalyticsService.shared.reportOpenScreen()
        view.backgroundColor = UIColor(resource: .ypMainBackground)
        setupUI()
        setupCollectionView()
        setupNavigationBar()
        
        trackerStore.onDidUpdate = { [weak self] in
            self?.loadTrackers()
        }
        
        recordStore.onDidUpdate = { [weak self] in
            self?.updateTrackers(for: self?.selectedDate ?? Date())
        }
        
        categoryStore.onDidUpdate = { [weak self] _ in
            self?.loadTrackers()
        }
        
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        loadTrackers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.reportCloseScreen()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(searchTextField)
        view.addSubview(collectionView)
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
        view.addSubview(filterButton)
        
        setupEmptyState()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        
        addButton.removeTarget(nil, action: nil, for: .allEvents)
        addButton.addTarget(self, action: #selector(addTrackerButtonTapped(_:)), for: .touchUpInside)
        
        let leftBarButtonItem = UIBarButtonItem(customView: addButton)
        leftBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 42).isActive = true
        leftBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        datePicker.removeTarget(nil, action: nil, for: .allEvents)
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        let rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = rightBarButtonItem
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
        
        let filterButtonHeight: CGFloat = 50
        let filterButtonBottomPadding: CGFloat = 16
        let collectionViewBottomOffset = filterButtonHeight + filterButtonBottomPadding
        
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
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            filterButton.heightAnchor.constraint(equalToConstant: filterButtonHeight),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -filterButtonBottomPadding),
            
        ])
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: collectionViewBottomOffset, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
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
    
    private func loadTrackers() {
        categories = trackerStore.fetchCategories()
        updateTrackers(for: selectedDate)
    }
    
    private func updateTrackers(for date: Date) {
        let searchText = searchTextField.text?.lowercased() ?? ""
        
        var filtered = categories.map { category in
            let trackers = category.trackers.filter {
                searchText.isEmpty ? true :
                $0.name.lowercased().contains(searchText)
            }
            return TrackerCategory(title: category.title, trackers: trackers)
        }.filter { !$0.trackers.isEmpty }
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let mappedWeekday = weekday == 1 ? 7 : weekday - 1
        
        filtered = filtered.map { category in
            let trackers = category.trackers.filter { tracker in
                guard let schedule = tracker.schedule else { return true }
                return schedule.days.contains { $0.rawValue == mappedWeekday }
            }
            return TrackerCategory(title: category.title, trackers: trackers)
        }.filter { !$0.trackers.isEmpty }
        
        displayedCategories = applyFilter(to: filtered, filter: currentFilter, for: date)
        
        collectionView.reloadData()
        updateEmptyState()
        updateEmptyStateForFilter()
    }
    
    
    private func updateEmptyState() {
        let hasTrackers = displayedCategories.contains { !$0.trackers.isEmpty }
        UIView.animate(withDuration: 0.25) {
            self.emptyStateImageView.alpha = hasTrackers ? 0 : 1
            self.emptyStateLabel.alpha = hasTrackers ? 0 : 1
            self.collectionView.alpha = hasTrackers ? 1 : 0
        }
    }
    
    private func applyFilter(to categories: [TrackerCategory],
                             filter: TrackerFilter,
                             for date: Date) -> [TrackerCategory] {
        
        let normalizedDate = getNormalizedDate(date)
        
        return categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                
                let isCompleted = isTrackerCompleted(tracker, on: normalizedDate)
                
                switch filter {
                case .allTrackers, .todayTrackers:
                    return true
                case .completed:
                    return isCompleted
                case .uncompleted:
                    return !isCompleted
                }
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
    }
    
    private func updateEmptyStateForFilter() {
        let hasTrackers = displayedCategories.contains { !$0.trackers.isEmpty }
        let hasAnyTrackers = categories.contains { !$0.trackers.isEmpty }
        
        if !hasAnyTrackers {
            emptyStateImageView.image = UIImage(resource: .errorStar)
            emptyStateLabel.text = NSLocalizedString("empty.trackers.title", comment: "Текст заглушки для пустого экрана трекеров")
            filterButton.isHidden = true
        } else if !hasTrackers {
            emptyStateImageView.image = UIImage(resource: .nothingFound)
            emptyStateLabel.text = NSLocalizedString("empty.search.title", comment: "Текст заглушки для пустого экрана трекеров")
            filterButton.isHidden = false
        } else {
            filterButton.isHidden = false
        }
        
        let showPlaceholder = !hasTrackers
        UIView.animate(withDuration: 0.25) {
            self.emptyStateImageView.alpha = showPlaceholder ? 1 : 0
            self.emptyStateLabel.alpha = showPlaceholder ? 1 : 0
            self.collectionView.alpha = showPlaceholder ? 0 : 1
        }
    }
    
    // MARK: - Actions
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = getNormalizedDate(sender.date)
        updateTrackers(for: selectedDate)
    }
    
    @objc private func addTrackerButtonTapped(_ sender: UIButton) {
        AnalyticsService.shared.reportClick(on: AnalyticsService.Item.addTrack)
        let habitVC = NewHabitCreationViewController()
        
        habitVC.onCreate = { [weak self] tracker, category in
            guard let self else { return }
            
            self.trackerStore.addTracker(tracker, category: category)
        }
        
        let nav = UINavigationController(rootViewController: habitVC)
        present(nav, animated: true)
    }
    
    @objc private func filterButtonTapped() {
        AnalyticsService.shared.reportClick(on: AnalyticsService.Item.filter)
        let filterVC = FiltersViewController(currentFilter: currentFilter)
        filterVC.delegate = self
        present(filterVC, animated: true)
    }
    
    @objc private func searchTextChanged() {
        updateTrackers(for: selectedDate)
    }
    
    // MARK: - Tracker Completion
    
    func getNormalizedDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }
    
    func completeTracker(_ tracker: Tracker, for date: Date) {
        let normalizedDate = getNormalizedDate(date)
        let record = TrackerRecord(trackerId: tracker.id, date: normalizedDate)
        recordStore.addRecord(record)
        StatisticsService.shared.incrementCompletedTrackers()
    }
    
    func uncompleteTracker(_ tracker: Tracker, for date: Date) {
        let normalizedDate = getNormalizedDate(date)
        let record = TrackerRecord(trackerId: tracker.id, date: normalizedDate)
        recordStore.removeRecord(record)
        StatisticsService.shared.decrementCompletedTrackers()
    }
    
    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        let normalizedDate = getNormalizedDate(date)
        let isCompleted = !recordStore.fetchRecords(for: normalizedDate, trackerId: tracker.id).isEmpty
        return isCompleted
    }
    
    // MARK: - Context Menu Actions
    
    private func editTracker(_ tracker: Tracker) {
        guard let category = categories.first(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) else {
            return
        }
        
        let completedDaysCount = recordStore.countCompletedDays(for: tracker.id)
        let habitVC = NewHabitCreationViewController(trackerToEdit: tracker, category: category, completedDays: completedDaysCount)
        
        habitVC.onCreate = { [weak self] updatedTracker, newCategory in
            guard let self else { return }
            let newCategoryTitle = newCategory?.title
            self.trackerStore.updateTracker(updatedTracker, newCategoryTitle: newCategoryTitle)
        }
        
        let nav = UINavigationController(rootViewController: habitVC)
        present(nav, animated: true)
    }
    
    private func confirmAndDeleteTracker(_ tracker: Tracker) {
        print("Подтверждение удаления трекера: \(tracker.id)")
        
        let alert = UIAlertController(title: "",
                                      message: "Уверены, что хотите удалить трекер?",
                                      preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.trackerStore.deleteTracker(id: tracker.id)
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
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
        let count = recordStore.fetchAllRecords(for: tracker.id).count
        let isFuture = Calendar.current.compare(selectedDate, to: Date(), toGranularity: .day) == .orderedDescending
        
        cell.configure(with: tracker, count: count, isCompleted: isCompleted, isFuture: isFuture)
        
        cell.onToggle = { [weak self] in
            guard let self else { return }
            
            AnalyticsService.shared.reportClick(on: AnalyticsService.Item.track)
            
            if isFuture { return }
            if isCompleted {
                self.uncompleteTracker(tracker, for: self.selectedDate)
            } else {
                self.completeTracker(tracker, for: self.selectedDate)
            }
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

// MARK: - UICollectionViewDelegate (Context Menu Preview)

extension TrackersViewController {
    
    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else {
            return nil
        }
        
        let targetView = cell.cardViewForPreview
        let parameters = UIPreviewParameters()
        parameters.visiblePath = UIBezierPath(roundedRect: targetView.bounds, cornerRadius: 16)
        
        let targetedPreview = UITargetedPreview(view: targetView, parameters: parameters)
        return targetedPreview
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController {
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        let tracker = displayedCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { [weak self] _ in
            
            let editAction = UIAction(title: NSLocalizedString("edit.context.menu", comment: "Действие Редактировать")) { _ in
                AnalyticsService.shared.reportClick(on: AnalyticsService.Item.edit)
                self?.editTracker(tracker)
            }
            
            let deleteAction = UIAction(title: NSLocalizedString("delete.context.menu", comment: "Действие Удалить"), attributes: .destructive) { _ in
                AnalyticsService.shared.reportClick(on: AnalyticsService.Item.delete)
                self?.confirmAndDeleteTracker(tracker)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        self.currentFilter = filter
        
        switch filter {
        case .todayTrackers:
            let today = Calendar.current.startOfDay(for: Date())
            selectedDate = today
            datePicker.setDate(today, animated: true)
            updateTrackers(for: today)
        case .allTrackers, .completed, .uncompleted:
            updateTrackers(for: selectedDate)
        }
    }
}

// MARK: - UITextFieldDelegate

extension TrackersViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
