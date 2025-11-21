import Foundation
import CoreData

final class TrackerRecordStore: NSObject {

    static let shared = TrackerRecordStore()
    
    var onDidUpdate: (() -> Void)?

    private let context: NSManagedObjectContext
    private let frc: NSFetchedResultsController<TrackerRecordCoreData>
    private var records: [TrackerRecord] = []
    
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

    func fetchRecords(for date: Date) -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        if let fetched = try? context.fetch(request) {
            records = fetched.compactMap { TrackerRecord(coreData: $0) }
        }
        return records.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func addRecord(_ record: TrackerRecord) {
        let entity = TrackerRecordCoreData(context: context)
        entity.trackerId = record.trackerId
        entity.date = record.date
        CoreDataStack.shared.saveContext()
        records.append(record)
        onDidUpdate?()
    }

    func removeRecord(_ record: TrackerRecord) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            record.trackerId as CVarArg,
            record.date as CVarArg
        )

        if let object = try? context.fetch(request).first {
            context.delete(object)
            CoreDataStack.shared.saveContext()
        }
        records.removeAll { $0.trackerId == record.trackerId && Calendar.current.isDate($0.date, inSameDayAs: record.date) }
        onDidUpdate?()
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onDidUpdate?()
    }
}
