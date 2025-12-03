import Foundation
import CoreData

protocol TrackerRecordStoreProtocol {
    func fetchRecords(for date: Date, trackerId: UUID) -> [TrackerRecord]
    func fetchAllRecords(for trackerId: UUID) -> [TrackerRecord]
    func countCompletedDays(for trackerId: UUID) -> Int
    func addRecord(_ record: TrackerRecord)
    func removeRecord(_ record: TrackerRecord)
    var onDidUpdate: (() -> Void)? { get set }
}
