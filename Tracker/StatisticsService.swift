import Foundation

final class StatisticsService {
    
    static let shared = StatisticsService()
    
    private let completedTrackersKey = "CompletedTrackersCount"
    
    private init() {}
    
    var completedTrackersCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: completedTrackersKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: completedTrackersKey)
        }
    }
    
    func incrementCompletedTrackers() {
        completedTrackersCount += 1
    }
    
    func decrementCompletedTrackers() {
        completedTrackersCount -= 1
        if completedTrackersCount < 0 {
            completedTrackersCount = 0
        }
    }
}
