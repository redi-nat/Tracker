import Foundation
import CoreData

final class TrackerRecordStore: NSObject {
    
    static let shared = TrackerRecordStore()
    
    private let context: NSManagedObjectContext
    private let frc: NSFetchedResultsController<TrackerRecordCoreData>
    
    var onDidUpdate: (() -> Void)?
    
    // MARK: - Init
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        self.frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        frc.delegate = self
        try? frc.performFetch()
    }
    
    // MARK: - Core Data Helper
    
    private func convert(coreData: TrackerRecordCoreData) -> TrackerRecord? {
        guard let id = coreData.trackerId, let date = coreData.date else {
            return nil
        }
        return TrackerRecord(trackerId: id, date: date)
    }
    
    // MARK: - Fetch: records for specific date & tracker
    
    func fetchRecords(for date: Date, trackerId: UUID) -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            trackerId as CVarArg,
            date as NSDate
        )
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let fetched = (try? context.fetch(request)) ?? []
        return fetched.compactMap { convert(coreData: $0) }
    }
    
    
    // MARK: - Remove record
    
    func removeRecord(_ record: TrackerRecord) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            record.trackerId as CVarArg,
            record.date as NSDate
        )
        request.predicate = predicate
        
        if let fetchedRecords = try? context.fetch(request) {
            if let objectToRemove = fetchedRecords.first {
                context.delete(objectToRemove)
                CoreDataStack.shared.saveContext()
                print("🗑️ SUCCESS: Record removed for ID \(record.trackerId) on date \(record.date)")
            } else {
                print("⚠️ WARNING: No record found to delete for ID \(record.trackerId) on date \(record.date).")
            }
        } else {
            print("🔥 ERROR: Failed to fetch records during removal attempt for ID \(record.trackerId)")
        }
        
        onDidUpdate?()
    }
    
    // MARK: - Fetch: records for specific date
    func fetchRecords(for date: Date) -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let fetched = (try? context.fetch(request)) ?? []
        
        return fetched.compactMap { convert(coreData: $0) }
            .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    // MARK: - Fetch: ALL records for tracker
    func fetchAllRecords(for trackerId: UUID) -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@",
            trackerId as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let fetched = (try? context.fetch(request)) ?? []
        return fetched.compactMap { convert(coreData: $0) }
    }
    
    // MARK: - Add record
    func addRecord(_ record: TrackerRecord) {
        let entity = TrackerRecordCoreData(context: context)
        entity.trackerId = record.trackerId
        entity.date = record.date
        
        CoreDataStack.shared.saveContext()
        
        onDidUpdate?()
    }
    
    // MARK: - Count completed days

    func countCompletedDays(for trackerId: UUID) -> Int {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "trackerId == %@",
            trackerId as CVarArg
        )
        
        do {
            let count = try context.count(for: request)
            return count != NSNotFound ? count : 0
        } catch {
            print("ERROR: Failed to count records for trackerId \(trackerId): \(error.localizedDescription)")
            return 0
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onDidUpdate?()
    }
}
