import XCTest
import SnapshotTesting
@testable import Tracker

extension TrackersViewController {
    
    func simulateSearch(text: String) {
        guard let textField = self.view.subviews.first(where: { $0 is UITextField }) as? UITextField else {
            XCTFail("searchTextField not found in view hierarchy.")
            return
        }
        textField.text = text
    }
    
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
}


final class TrackersSnapshotTests: XCTestCase {
    
    private var mockTrackerStore: MockTrackerStore!
    private var mockRecordStore: MockTrackerRecordStore!
    private var mockCategoryStore: MockTrackerCategoryStore!
    
    override func setUp() {
        super.setUp()
        //isRecording = true
        
        mockTrackerStore = MockTrackerStore()
        mockRecordStore = MockTrackerRecordStore()
        mockCategoryStore = MockTrackerCategoryStore()
    }
    
    override func tearDown() {
        mockTrackerStore = nil
        mockRecordStore = nil
        mockCategoryStore = nil
        super.tearDown()
    }
    
    private func createVC() -> TrackersViewController {
        let vc = TrackersViewController(
            trackerStore: mockTrackerStore,
            recordStore: mockRecordStore,
            categoryStore: mockCategoryStore
        )
        vc.loadViewIfNeeded()
        return vc
    }
    
    private func setupMockTrackers() {
        let mockTracker1 = Tracker(
            id: UUID(uuidString: "DEADBEEF-0000-0000-0000-000000000001")!,
            name: "Бегит",
            color: .systemRed,
            emoji: "🎸",
            schedule: TrackerSchedule(days: [.monday, .tuesday])
        )
        let mockTracker2 = Tracker(
            id: UUID(uuidString: "DEADBEEF-0000-0000-0000-000000000002")!,
            name: "Анжуманя",
            color: .systemBlue,
            emoji: "🥇",
            schedule: TrackerSchedule(days: [.monday, .wednesday, .thursday])
        )
        
        mockTrackerStore.mockCategories = [
            TrackerCategory(title: "Спорт", trackers: [mockTracker1, mockTracker2])
        ]
        mockCategoryStore.mockCategories = mockTrackerStore.mockCategories
    }
    
    private func takeSnapshot(
        vc: TrackersViewController,
        name: String,
        style: UIUserInterfaceStyle
    ) {
        let traits = UITraitCollection(userInterfaceStyle: style)
        
        assertSnapshot(
            matching: vc,
            as: .image(on: .iPhone13Pro, traits: traits),
            named: "\(name)_\(style == .dark ? "Dark" : "Light")"
        )
    }
    
    func testTrackersScreen_DefaultState_WithTrackers() throws {
        let vc = createVC()
        setupMockTrackers()
        
        vc.simulateDateChange(to: Date())
        vc.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        
        takeSnapshot(vc: vc, name: "WithTrackers_Default", style: .light)
        takeSnapshot(vc: vc, name: "WithTrackers_Default", style: .dark)
    }
    
    func testTrackersScreen_WithTrackers_Tuesday() throws {
        let vc = createVC()
        setupMockTrackers()
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        components.weekday = 3
        let tuesday = calendar.date(from: components) ?? Date()
        
        vc.simulateDateChange(to: tuesday)
        
        takeSnapshot(vc: vc, name: "WithTrackers_Tuesday", style: .light)
        takeSnapshot(vc: vc, name: "WithTrackers_Tuesday", style: .dark)
    }
    
    func testTrackersScreen_SearchResults_NotFound() throws {
        let vc = createVC()
        setupMockTrackers()
        
        vc.simulateSearch(text: "qwerty123")
        
        takeSnapshot(vc: vc, name: "SearchResults_NotFound", style: .light)
        takeSnapshot(vc: vc, name: "SearchResults_NotFound", style: .dark)
    }
    
    func testTrackersScreen_EmptyState() throws {
        let vc = createVC()
        takeSnapshot(vc: vc, name: "EmptyState", style: .light)
        takeSnapshot(vc: vc, name: "EmptyState", style: .dark)
    }
}

final class MockTrackerStore: TrackerStoreProtocol {
    var onDidUpdate: (() -> Void)?
    var mockCategories: [TrackerCategory] = []
    
    func fetchCategories() -> [TrackerCategory] {
        return mockCategories
    }
    
    func fetchTrackers() -> [Tracker] {
        return mockCategories.flatMap { $0.trackers }
    }
    
    func deleteTracker(id: UUID) {
    }
    
    func updateTracker(_ tracker: Tracker, newCategoryTitle: String?) {
    }
    
    func addTracker(_ tracker: Tracker, category: TrackerCategory?) {
    }
}

final class MockTrackerRecordStore: TrackerRecordStoreProtocol {
    var onDidUpdate: (() -> Void)?
    var completedRecords: [TrackerRecord] = []
    
    func fetchRecords(for date: Date, trackerId: UUID) -> [TrackerRecord] {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        return completedRecords.filter {
            $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: normalizedDate)
        }
    }
    
    func fetchAllRecords(for trackerId: UUID) -> [TrackerRecord] {
        return completedRecords.filter { $0.trackerId == trackerId }
    }
    
    func countCompletedDays(for trackerId: UUID) -> Int {
        return fetchAllRecords(for: trackerId).count
    }
    
    func addRecord(_ record: TrackerRecord) {
        completedRecords.append(record)
    }
    
    func removeRecord(_ record: TrackerRecord) {
        if let index = completedRecords.firstIndex(where: { $0.trackerId == record.trackerId && Calendar.current.isDate($0.date, inSameDayAs: record.date) }) {
            completedRecords.remove(at: index)
        }
    }
}

final class MockTrackerCategoryStore: TrackerCategoryStoreProtocol {
    var onDidUpdate: ((TrackerCategoryStore) -> Void)?
    var mockCategories: [TrackerCategory] = []
    
    func fetchCategories() -> [TrackerCategory] {
        return mockCategories
    }
}

