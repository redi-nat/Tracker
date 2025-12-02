import Foundation
import CoreData

protocol TrackerCategoryStoreProtocol {
    func fetchCategories() -> [TrackerCategory]
    var onDidUpdate: ((TrackerCategoryStore) -> Void)? { get set }
}
