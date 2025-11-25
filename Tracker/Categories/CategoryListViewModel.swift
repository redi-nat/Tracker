import Foundation

final class CategoryListViewModel {
    
    // MARK: - Dependencies
    
    private let categoryStore: TrackerCategoryStore
    
    // MARK: - Bindings & Callbacks
    var onCategorySelected: ((TrackerCategory) -> Void)?
    var onUpdate: (() -> Void)?
    private(set) var selectedCategoryIndexPath: IndexPath?
    
    var store: TrackerCategoryStore {
        return categoryStore
    }
    // MARK: - Data
    
    private var categories: [TrackerCategory] = []
    
    // MARK: - Initialization
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        self.categoryStore.onDidUpdate = { [weak self] _ in
            self?.loadCategories()
            self?.onUpdate?()
        }
        loadCategories()
    }
    
    // MARK: - Public API
    
    func loadCategories() {
        categories = categoryStore.fetchCategories()
    }
    
    func getAllCategoryTitles() -> [String] {
        return categories.map { $0.title }
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String {
        return categories[indexPath.row].title
    }
    
    func numberOfCategories() -> Int {
        return categories.count
    }
    
    func didSelectCategory(at indexPath: IndexPath) {
        if selectedCategoryIndexPath == indexPath {
            selectedCategoryIndexPath = nil
        } else {
            selectedCategoryIndexPath = indexPath
        }
        
        onUpdate?()
        
        if let selectedIndexPath = selectedCategoryIndexPath {
            let selectedCategory = categories[selectedIndexPath.row]
            onCategorySelected?(selectedCategory)
        }
    }
    
    func isCategorySelected(at indexPath: IndexPath) -> Bool {
        return selectedCategoryIndexPath == indexPath
    }
    
    func addCategory(_ category: TrackerCategory) {
        categoryStore.addCategory(category)
    }
}
