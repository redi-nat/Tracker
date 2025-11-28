import Foundation
import CoreData

final class TrackerStore: NSObject {

    static let shared = TrackerStore()
    
    var onDidUpdate: (() -> Void)?

    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCoreData>

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context

        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()
        self.fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }

    // MARK: - Public API

    func fetchTrackers() -> [Tracker] {
        fetchedResultsController.fetchedObjects?.compactMap { Tracker(coreData: $0) } ?? []
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let trackers = fetchTrackers()
        let categoriesCD = (try? context.fetch(TrackerCategoryCoreData.fetchRequest())) ?? []
        
        return categoriesCD.map { categoryCD in
            let trackersInCategoryCD = (categoryCD.trackers as? Set<TrackerCoreData>) ?? []
            let trackersInCategory = trackers.filter { tracker in
                trackersInCategoryCD.contains(where: { $0.id == tracker.id })
            }
            return TrackerCategory(title: categoryCD.title ?? "Без категории",
                                   trackers: trackersInCategory)
        }
    }

    func addTracker(_ tracker: Tracker, category: TrackerCategory? = nil) {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)

        if let existing = try? context.fetch(request).first {
            existing.configure(from: tracker, context: context)
            try? context.save()
            return
        }

        let entity = TrackerCoreData(context: context)
        entity.configure(from: tracker, context: context)

        let categoryTitle = category?.title ?? "Без категории"
        let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)

        let categoryCD: TrackerCategoryCoreData
        if let fetchedCategory = try? context.fetch(categoryRequest).first {
            categoryCD = fetchedCategory
        } else {
            categoryCD = TrackerCategoryCoreData(context: context)
            categoryCD.title = categoryTitle
        }

        entity.category = categoryCD

        try? context.save()
    }


    func deleteTracker(id: UUID) {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        if let object = try? context.fetch(request).first {
            context.delete(object)
            CoreDataStack.shared.saveContext()
            onDidUpdate?()
        }
    }
    
    func printAllTrackers() {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        if let trackers = try? context.fetch(request) {
            for t in trackers {
                print("Tracker: \(t.name ?? "nil"), id: \(t.id?.uuidString ?? "nil")")
            }
        }
    }

    func updateTracker(_ tracker: Tracker, newCategoryTitle: String? = nil) {
        
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)

        guard let existingTracker = try? context.fetch(request).first else {
            print("Ошибка: Трекер с ID \(tracker.id) для обновления не найден")
            return
        }

        existingTracker.configure(from: tracker, context: context)
        
        if let newTitle = newCategoryTitle, newTitle != existingTracker.category?.title {
            
            let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            categoryRequest.predicate = NSPredicate(format: "title == %@", newTitle)
            
            let categoryCD: TrackerCategoryCoreData
            if let fetchedCategory = try? context.fetch(categoryRequest).first {
                categoryCD = fetchedCategory
            } else {
                categoryCD = TrackerCategoryCoreData(context: context)
                categoryCD.title = newTitle
            }
            
            existingTracker.category = categoryCD
        }

        CoreDataStack.shared.saveContext()
        onDidUpdate?()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onDidUpdate?()
    }
}
