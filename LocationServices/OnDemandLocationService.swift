import Foundation
import CoreLocation

@MainActor
class OnDemandLocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    // 位置情報の座標用変数
    @Published private(set) var currentLocation: CLLocation?
    // 位置情報取得履歴の保存
    @Published private(set) var locationHistory: [CLLocation] = []
    // リクエスト中フラグを追加
    @Published private(set) var isRequestingLocation = false

    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocationUpdate(activityType: ActivityType, accuracyLevel: LocationAccuracyLevel) {

        guard !isRequestingLocation else {
            print("既に位置情報リクエスト中です。")
            return
        }
        // リクエスト開始フラグを立てる
        isRequestingLocation = true
        locationManager.activityType = activityType.clActivityType
        locationManager.desiredAccuracy = accuracyLevel.clLocationAccuracy
        let authStatus = locationManager.authorizationStatus

        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            // エラー時はフラグを戻す
            isRequestingLocation = false
            print("位置情報を許可してください")
            break
        }
    }

    // MARK: CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task {
            await MainActor.run {
                // 既存のデータと比較して、新しいデータだけを追加
                let isNewLocation = locationHistory.isEmpty ||
                    location.timestamp != locationHistory.last?.timestamp
                if isNewLocation {
                    currentLocation = location
                    locationHistory.append(location)
                    isRequestingLocation = false
                    print("新しい位置情報を追加: \(location.timestamp)")
                } else {
                    print("重複した位置情報をスキップ: \(location.timestamp)")
                    // リクエスト終了フラグを下げる
                    isRequestingLocation = false

                }
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        Task {
            await MainActor.run {
                // エラー時もフラグを下げる
                isRequestingLocation = false
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
                //TODO　更新された権限によって、処理をわける部分の実装
                Task {
                    await MainActor.run {
                        locationManager.requestLocation()
                    }
                }
            }
    }


