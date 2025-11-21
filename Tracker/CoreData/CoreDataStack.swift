import CoreData
import UIKit

final class CoreDataStack {

    static let shared = CoreDataStack()

    private init() {}

    // MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerDataModel")

        if let storeDescription = container.persistentStoreDescriptions.first {
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.shouldInferMappingModelAutomatically = true
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("❌ Ошибка загрузки хранилища: \(error)")
            } else {
                print("Хранилище загружено: \(storeDescription.url?.lastPathComponent ?? "")")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()


    // MARK: - Context для работы
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Save
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("❌ Error saving context: \(error)")
            }
        }
    }

    // MARK: - Path helper
    private func storeURL(fileName: String) -> URL {
            guard let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                fatalError("❌ Document directory not found")
            }
            return folder.appendingPathComponent(fileName)
        }
}

extension TrackerCoreData {
    func configure(from tracker: Tracker, context: NSManagedObjectContext) {
        self.id = tracker.id
        self.name = tracker.name
        self.emoji = tracker.emoji
        self.color = tracker.color.toHexString()
        
        if let schedule = tracker.schedule {
            self.schedule = try? JSONEncoder().encode(schedule)
        } else {
            self.schedule = nil
        }
    }
}

extension Tracker {
    init?(coreData: TrackerCoreData) {
        guard
            let name = coreData.name,
            let emoji = coreData.emoji,
            let colorHex = coreData.color
        else { return nil }

        let schedule: TrackerSchedule?
        if let scheduleData = coreData.schedule {
            schedule = try? JSONDecoder().decode(TrackerSchedule.self, from: scheduleData)
        } else {
            schedule = nil
        }

        self = Tracker(
            id: coreData.id ?? UUID(),
            name: name,
            color: UIColor(hex: colorHex),
            emoji: emoji,
            schedule: schedule
        )
    }
}

extension TrackerCategoryCoreData {
    func configure(from category: TrackerCategory, context: NSManagedObjectContext) {

        self.title = category.title

        if let trackersSet = self.trackers as? Set<TrackerCoreData> {
            trackersSet.forEach { context.delete($0) }
        }

        let newTrackers = category.trackers.map { tracker -> TrackerCoreData in
            let entity = TrackerCoreData(context: context)
            entity.configure(from: tracker, context: context)
            return entity
        }

        self.trackers = NSSet(array: newTrackers)
    }
}

extension TrackerCategory {
    init?(coreData: TrackerCategoryCoreData) {
        guard let title = coreData.title else { return nil }

        let trackers: [Tracker] =
            (coreData.trackers as? Set<TrackerCoreData>)?
                .compactMap { Tracker(coreData: $0) } ?? []

        self = TrackerCategory(title: title, trackers: trackers)
    }
}

extension TrackerRecordCoreData {
    func configure(from record: TrackerRecord, context: NSManagedObjectContext) {
        self.date = record.date
    }
}


extension TrackerRecord {
    init?(coreData: TrackerRecordCoreData) {
        guard
            let tracker = coreData.tracker,
            let id = tracker.id,
            let date = coreData.date
        else { return nil }
        
        self = TrackerRecord(
            trackerId: id,
            date: date
        )
    }
}



