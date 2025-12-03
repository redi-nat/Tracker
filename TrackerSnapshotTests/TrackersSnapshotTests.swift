import XCTest
import SnapshotTesting
@testable import Tracker

extension TrackersViewController {
    
    func simulateDateChange(to date: Date) {
        let mockPicker = UIDatePicker()
        mockPicker.date = date
        
        let selector = Selector(("dateChanged:"))
        if self.responds(to: selector) {
            self.perform(selector, with: mockPicker)
        } else {
            XCTFail("Private method dateChanged(_:) not found or not @objc.")
        }
    }
    
    func simulateSearch(text: String) {
        
        guard let searchBar = self.view.subviews.compactMap({ $0 as? UISearchBar }).first else {
            XCTFail("UISearchBar not found in view hierarchy.")
            return
        }
        
        searchBar.text = text

        if let delegate = self as? UISearchBarDelegate {
            delegate.searchBar?(searchBar, textDidChange: text)
        }
    }
}


final class TrackersSnapshotTests: XCTestCase {
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        isRecording = true // ⚠️ Раскомментируйте ТОЛЬКО для записи эталонных изображений
    }
    
    private func createVC() -> TrackersViewController {
        let vc = TrackersViewController()
        vc.loadViewIfNeeded()
        return vc
    }
    
    private func setupMockTrackers() {
        //TrackerStore.shared.clearTestData()
        
        let mockTracker1 = Tracker(
            id: UUID(),
            name: "Бегит",
            color: .red,
            emoji: "🎸",
            schedule: TrackerSchedule(days: [.monday, .tuesday])
        )
        let mockTracker2 = Tracker(
            id: UUID(),
            name: "Анжуманя",
            color: .blue,
            emoji: "🥇",
            schedule: TrackerSchedule(days: [.monday, .wednesday, .thursday])
        )
        
        TrackerStore.shared.addTracker(mockTracker1)
        TrackerStore.shared.addTracker(mockTracker2)
    }
    
    
    func testTrackersScreen_EmptyState() throws {
        let vc = createVC()
        assertSnapshot(matching: vc, as: .image(on: .iPhone13Pro), named: "EmptyState")
    }
    
    
    func testTrackersScreen_WithTrackers_Tuesday() throws {
        let vc = createVC()
        setupMockTrackers()

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        components.weekday = 2
        let tuesday = calendar.date(from: components) ?? Date()
        
        vc.simulateDateChange(to: tuesday)
        
        assertSnapshot(matching: vc, as: .image(on: .iPhone13Pro), named: "WithTrackers_Tuesday")
    }
    
    
    func testTrackersScreen_SearchResults_NotFound() throws {
        let vc = createVC()
        setupMockTrackers()
        
        vc.simulateSearch(text: "qwerty123")
        
        assertSnapshot(matching: vc, as: .image(on: .iPhone13Pro), named: "SearchResults_NotFound")
    }
}
