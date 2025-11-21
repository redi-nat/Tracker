import Foundation
import CoreData

final class TrackerCategoryStore: NSObject {

    var onDidUpdate: (() -> Void)?

    private let context: NSManagedObjectContext
    private let frc: NSFetchedResultsController<TrackerCategoryCoreData>

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context

        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

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

    func fetchCategories() -> [TrackerCategory] {
        frc.fetchedObjects?.compactMap { TrackerCategory(coreData: $0) } ?? []
    }

    func addCategory(_ category: TrackerCategory) {
        let entity = TrackerCategoryCoreData(context: context)
        entity.configure(from: category, context: context)
        CoreDataStack.shared.saveContext()
        onDidUpdate?()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onDidUpdate?()
    }
}
