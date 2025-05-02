import Foundation
import CoreLocation

enum LocationAccuracyLevel: String, CaseIterable, Hashable {
    case bestForNavigation = "bestForNavigation"
    case best = "best"
    case nearestTenMeters = "nearestTenMeters"

    var displayName: String {
        switch self {
        case .bestForNavigation:
            return "ナビ用最高精度"
        case .best:
            return "最高精度"
        case .nearestTenMeters:
            return "10メートル精度"
        }
    }

    // CLLocationAccuracyへの変換
    var clLocationAccuracy: CLLocationAccuracy {
        switch self {
        case .bestForNavigation:
            return kCLLocationAccuracyBestForNavigation
        case .best:
            return kCLLocationAccuracyBest
        case .nearestTenMeters:
            return kCLLocationAccuracyNearestTenMeters
        }
    }
}
