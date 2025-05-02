import Foundation
import CoreLocation

enum ActivityType: String, CaseIterable, Hashable {
    case fitness = "fitness"
    case otherNavigation = "otherNavigation"
    case other = "other"

    var displayName: String {
        switch self {
        case .fitness:
            return "フィットネス"
        case .otherNavigation:
            return "ナビゲーション"
        case .other:
            return "その他"
        }
    }

    // CLActivityTypeへの変換
    var clActivityType: CLActivityType {
        switch self {
        case .fitness:
            return .fitness
        case .otherNavigation:
            return .otherNavigation
        case .other:
            return .other
        }
    }
}
