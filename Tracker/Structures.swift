import Foundation
import UIKit

struct TrackerSchedule {
    let days: [Weekday]
    
    enum Weekday: Int {
        case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    }
}

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: TrackerSchedule?
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let trackerId: UUID
    let date: Date
}



