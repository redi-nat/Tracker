import Foundation
import UIKit

struct TrackerSchedule {
    let days: [Weekday]
    
    enum Weekday: Int {
        case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    }
}

extension TrackerSchedule {
    var daysText: String {
        if days.count == 7 {
            return "Каждый день"
        } else {
            return days.map { $0.shortName }.joined(separator: ", ")
        }
    }
}

extension TrackerSchedule.Weekday {
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}
