import UIKit

final class CreateCategoryViewController: UIViewController {
    
    private let categoryStore: TrackerCategoryStore
    
    var onCategoryCreated: ((TrackerCategory) -> Void)?
    var onCategoryUpdated: (() -> Void)?
    private var isEditingMode = false
    private var categoryToEditTitle: String?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите название категории"
        tf.backgroundColor = UIColor(resource: .ypBackgroundGray)
        tf.layer.cornerRadius = 16
        tf.layer.masksToBounds = true
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        updateDoneButtonState()
        
        if isEditingMode {
            updateUIForEditing()
        }
    }
    
    private func setupUI() {
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        view.addSubview(textField)
        view.addSubview(titleLabel)
        setupDoneButton()
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -22),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func setupDoneButton() {
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }
    
    private func updateUIForEditing() {
        titleLabel.text = "Редактирование категории"
        textField.text = categoryToEditTitle
        doneButton.setTitle("Готово", for: .normal)
    }
    
    private func updateDoneButtonState() {
        guard let text = textField.text else { return }
        let isNameValid = !text.trimmingCharacters(in: .whitespaces).isEmpty
        
        UIView.animate(withDuration: 0.25) {
            if isNameValid {
                self.doneButton.backgroundColor = UIColor(resource: .ypBlack)
                self.doneButton.setTitleColor(.white, for: .normal)
                self.doneButton.isEnabled = true
            } else {
                self.doneButton.backgroundColor = UIColor(resource: .ypGray3)
                self.doneButton.setTitleColor(.white, for: .normal)
                self.doneButton.isEnabled = false
            }
        }
    }
    
    func configureForEditing(categoryTitle: String) {
        self.isEditingMode = true
        self.categoryToEditTitle = categoryTitle
        
        if isViewLoaded {
            updateUIForEditing()
        }
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateDoneButtonState()
    }
    
    @objc private func doneTapped() {
        guard let newTitle = textField.text, !newTitle.isEmpty else { return }
        
        if isEditingMode, let oldTitle = categoryToEditTitle {
            categoryStore.updateCategoryTitle(oldTitle: oldTitle, newTitle: newTitle)
            onCategoryUpdated?()
            dismiss(animated: true)
        } else {
            let newCategory = TrackerCategory(title: newTitle, trackers: [])
            onCategoryCreated?(newCategory)
        }
        
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

