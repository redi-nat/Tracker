import Foundation

enum TrackerFilter: String, CaseIterable {
    case allTrackers = "Все трекеры"
    case todayTrackers = "Трекеры на сегодня"
    case completed = "Завершённые"
    case uncompleted = "Незавершённые"
    
    var index: Int {
        switch self {
        case .allTrackers: return 0
        case .todayTrackers: return 1
        case .completed: return 2
        case .uncompleted: return 3
        }
    }
}
