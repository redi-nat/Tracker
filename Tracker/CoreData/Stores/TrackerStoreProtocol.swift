import Foundation
import CoreData

protocol TrackerStoreProtocol {
    var onDidUpdate: (() -> Void)? { get set }

    func fetchTrackers() -> [Tracker]
    func addTracker(_ tracker: Tracker, category: TrackerCategory)
    func deleteTracker(id: UUID)
}
