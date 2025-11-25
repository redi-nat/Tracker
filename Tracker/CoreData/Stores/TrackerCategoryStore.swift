import Foundation
import CoreData

final class TrackerCategoryStore: NSObject {

    static let shared = TrackerCategoryStore()
    var onDidUpdate: ((TrackerCategoryStore) -> Void)?

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
        do {
                    try frc.performFetch()
                } catch {
                    print("Ошибка при выполнении выборки категорий: \(error.localizedDescription)")
                }
    }

    func fetchCategories() -> [TrackerCategory] {
        return frc.fetchedObjects?.compactMap {
                    TrackerCategory(coreData: $0)
                } ?? []
    }

    func addCategory(_ category: TrackerCategory) {
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = category.title 
        CoreDataStack.shared.saveContext()
    }
    
    func fetchCategoryCoreData(withTitle title: String) -> TrackerCategoryCoreData? {
            let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "title == %@", title)
            request.fetchLimit = 1

            do {
                let results = try context.fetch(request)
                return results.first
            } catch {
                print("Ошибка при поиске категории с заголовком \(title): \(error.localizedDescription)")
                return nil
            }
        }
    
    func fetchOrCreateDefaultCategory() -> TrackerCategoryCoreData {
            let defaultTitle = "Без категории"
            
            if let existingCategory = fetchCategoryCoreData(withTitle: defaultTitle) {
                return existingCategory
            }

            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = defaultTitle
            CoreDataStack.shared.saveContext()
            return newCategory
        }
    
    func updateCategoryTitle(oldTitle: String, newTitle: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", oldTitle)

        do {
            let categories = try context.fetch(request)
            
            guard let categoryToUpdate = categories.first else {
                print("Ошибка: Категория '\(oldTitle)' не найдена для обновления")
                return
            }
            
            categoryToUpdate.title = newTitle
            CoreDataStack.shared.saveContext()
            
        } catch {
            print("Ошибка при обновлении названия категории '\(oldTitle)': \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(withTitle title: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)

        do {
            let categories = try context.fetch(request)
            guard let categoryToDelete = categories.first else { return }
            
            if categoryToDelete.title == "Без категории" {
                print("Попытка удалить категорию 'Без категории' — операция отменена")
                return
            }
            
            let defaultCategory = fetchOrCreateDefaultCategory()
            
            if let trackersToMove = categoryToDelete.trackers as? Set<TrackerCoreData> {
                for tracker in trackersToMove {
                    tracker.category = defaultCategory
                }
            }
            
            context.delete(categoryToDelete)
            CoreDataStack.shared.saveContext()
            
        } catch {
            print("Ошибка при удалении категории: \(error.localizedDescription)")
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
                    self.onDidUpdate?(self)
                }
    }
}
