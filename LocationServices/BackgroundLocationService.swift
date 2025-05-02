import Foundation
import CoreLocation

class BackgroundLocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()

    @Published private(set) var currentLocation: CLLocation?
    // 位置情報取得履歴の保存
    @Published private(set) var locationHistory: [CLLocation] = []
    // リクエスト中フラグを追加
    @Published private(set) var isRequestingLocation = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 10メートル以上の移動があった場合のみ更新を受け取る
        locationManager.distanceFilter = 10.0
    }

    func requestLocationUpdate(activityType: ActivityType, accuracyLevel: LocationAccuracyLevel) {

        guard !isRequestingLocation else {
            print("既に位置情報リクエスト中です。")
            return
        }
        isRequestingLocation = true
        stopTrackingAndClearLocationHistory()
        locationManager.activityType = activityType.clActivityType
        locationManager.desiredAccuracy = accuracyLevel.clLocationAccuracy

        let authStatus = locationManager.authorizationStatus

        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            // 既にWhenInUse権限がある場合は位置情報取得を開始
            locationManager.startUpdatingLocation()
            // 必要に応じてAlways権限をリクエスト
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }

    // 設定情報更新のための位置情報更新処理の停止・履歴の削除
    func stopTrackingAndClearLocationHistory() {
        locationHistory = []
        locationManager.stopUpdatingLocation()
    }


    // MARK: CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task {
            await MainActor.run {
                if isRequestingLocation {
                    isRequestingLocation = false
                }
                currentLocation = location
                locationHistory.append(location)
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task {
            await MainActor.run {
                switch manager.authorizationStatus {
                case .authorizedAlways:
                    locationManager.startUpdatingLocation()
                    locationManager.allowsBackgroundLocationUpdates = true
                case .authorizedWhenInUse:
                    locationManager.startUpdatingLocation()
                    locationManager.requestAlwaysAuthorization()
                case .denied, .restricted:
                    print("Location permissions denied or restricted")
                    isRequestingLocation = false
                default:
                    break
                }
            }
        }
    }
}
