import Foundation
import CoreData

protocol TrackerStoreProtocol {
    var onDidUpdate: (() -> Void)? { get set }
    func fetchCategories() -> [TrackerCategory]
    func fetchTrackers() -> [Tracker]
    func addTracker(_ tracker: Tracker, category: TrackerCategory?)
    func deleteTracker(id: UUID)
    func updateTracker(_ tracker: Tracker, newCategoryTitle: String?)
}
