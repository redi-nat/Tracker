import UIKit

final class CategoryListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: CategoryListViewModel
    private var categoryTitles: [String] = []
    private var tableHeightConstraint: NSLayoutConstraint?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = UIColor(resource: .ypBackgroundGray)
        tv.layer.cornerRadius = 16
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.isScrollEnabled = false
        tv.estimatedRowHeight = 75
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Empty State
    
    private let emptyImageView: UIImageView = {
        let errorStar = UIImage(resource: .errorStar)
        let imageView = UIImageView(image: errorStar)
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // MARK: - Init
    
    init(viewModel: CategoryListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    
    // MARK: - ViewModel Binding
    
    private func setupViewModel() {
        
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.categoryTitles = self.viewModel.getAllCategoryTitles()
                
                self.tableView.reloadData()
                self.updateTableHeight()
                self.updateEmptyState()
            }
        }
        
        viewModel.loadCategories()
        viewModel.onUpdate?()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -22),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        setupAddButton()
        setupTableView()
        setupEmptyState()
        updateEmptyState()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomCategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint?.isActive = true
    }
    
    private func setupAddButton() {
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        addButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
    }
    
    private func setupEmptyState() {
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    // MARK: - Empty State Logic
    
    private func updateEmptyState() {
        let hasCategories = !categoryTitles.isEmpty
        
        tableView.alpha = hasCategories ? 1 : 0
        emptyImageView.alpha = hasCategories ? 0 : 1
        emptyLabel.alpha = hasCategories ? 0 : 1
    }
    
    private func openCreateCategoryScreen() {
        let createVC = CreateCategoryViewController(categoryStore: self.viewModel.store)
        createVC.onCategoryCreated = { [weak self] newCategory in
            self?.viewModel.addCategory(newCategory)
        }
        navigationController?.pushViewController(createVC, animated: true)
    }
    
    private func updateTableHeight() {
        let newHeight = tableView.contentSize.height
        if tableHeightConstraint?.constant != newHeight {
            tableHeightConstraint?.constant = newHeight
        }
    }
    
    // MARK: - Actions
    
    @objc private func addCategoryTapped() {
        openCreateCategoryScreen()    }
}


// MARK: - UITableViewDataSource

extension CategoryListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CustomCategoryCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(resource: .ypBackgroundGray)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textAlignment = .left
        
        let title = viewModel.categoryTitle(at: indexPath)
        cell.configure(with: title)
        
        if viewModel.isCategorySelected(at: indexPath) {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}


// MARK: - UITableViewDelegate

extension CategoryListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectCategory(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        
        let categoryTitle = viewModel.categoryTitle(at: indexPath)
        guard categoryTitle != "Без категории" else { return nil }
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: {
                return nil
            },
            actionProvider: { [weak self] _ in
                guard let self = self else { return nil }
                
                let editAction = UIAction(title: "Редактировать", image: nil) { _ in
                    self.editCategory(title: categoryTitle)
                }
                
                let deleteAction = UIAction(title: "Удалить", image: nil, attributes: .destructive) { _ in
                    self.confirmAndDeleteCategory(title: categoryTitle)
                }
                
                return UIMenu(children: [editAction, deleteAction])
            }
        )
    }
    
    
    private func editCategory(title: String) {
        let createVC = CreateCategoryViewController(categoryStore: self.viewModel.store)
        
        createVC.configureForEditing(categoryTitle: title)
        
        let nav = UINavigationController(rootViewController: createVC)
        present(nav, animated: true)
    }
    
    private func confirmAndDeleteCategory(title: String) {
        let alert = UIAlertController(
            title: "",
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.store.deleteCategory(withTitle: title)
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

