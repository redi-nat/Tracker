import Foundation
import YandexMobileMetrica

final class AnalyticsService {
    
    static let shared = AnalyticsService()
    
    private init() {}
        
    func report(event: String, params: [AnyHashable: Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
        
        #if DEBUG
        print("[Metrica Event] Event: \(event), Params: \(params)")
        #endif
    }
        
    func reportOpenScreen() {
        report(event: "open", params: ["screen": "Main"])
    }
    
    func reportCloseScreen() {
        report(event: "close", params: ["screen": "Main"])
    }
    
    func reportClick(on item: String) {
        report(event: "click", params: [
            "screen": "Main",
            "item": item
        ])
    }
}

extension AnalyticsService {
    enum Item {
        static let addTrack = "add_track"
        static let track = "track"
        static let filter = "filter"
        static let edit = "edit"
        static let delete = "delete"
    }
}
