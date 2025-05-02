import SwiftUI
import CoreLocation

struct ContentView: View {

    @StateObject var locationService = OnDemandLocationService()
    //@StateObject var locationService = BackgroundLocationService()
    //@StateObject var locationService = ForegroundLocationService()

    @State private var selectedActivityType: ActivityType = .other
    @State private var selectedAccuracyLevel: LocationAccuracyLevel = .best

    var body: some View {
        if locationService.isRequestingLocation {
            loadingOverlay
        } else {
            VStack {
                Text("位置情報検証アプリ")
                // 位置情報の表示
                if let location = locationService.currentLocation {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("位置情報")
                            .font(.headline)

                        Text("緯度: \(location.coordinate.latitude, specifier: "%.6f")")
                        Text("経度: \(location.coordinate.longitude, specifier: "%.6f")")
                        Text("取得時刻: \(formattedTime(location.timestamp))")
                            .foregroundColor(.blue)

                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                } else {
                    Text("位置情報が取得できていません")
                        .foregroundColor(.secondary)
                }
                Spacer()
                    .frame(height: 30)

                // 精度用ピッカー
                Picker("取得精度", selection: $selectedAccuracyLevel) {
                    ForEach(LocationAccuracyLevel.allCases, id: \.self) { accuracyLevel in
                        Text(accuracyLevel.displayName).tag(accuracyLevel)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                // Activity用ピッカー
                Picker("ActivityType", selection: $selectedActivityType) {
                    ForEach(ActivityType.allCases, id: \.self) { activityType in
                        Text(activityType.displayName).tag(activityType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Spacer()
                    .frame(height: 20)
                Button(action: {
                    locationService.requestLocationUpdate(
                        activityType: selectedActivityType,
                        accuracyLevel:  selectedAccuracyLevel
                    )
                }, label: {
                    Text("位置情報を取得")
                })
                .padding()
                .accentColor(Color.white)
                .background(Color.blue)


                // 位置情報履歴の表示
                VStack(alignment: .leading) {
                    Text("履歴")
                        .font(.headline)
                        .padding(.top)

                    if locationService.locationHistory.isEmpty {
                        Text("履歴がありません")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        List {
                            ForEach(locationService.locationHistory.indices, id: \.self) { index in
                                let locationData = locationService.locationHistory[index]
                                VStack(alignment: .leading) {
                                    Text("記録 #\(index + 1)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    Text("緯度: \(locationData.coordinate.latitude, specifier: "%.6f")")
                                    Text("経度: \(locationData.coordinate.longitude, specifier: "%.6f")")
                                    Text("時刻: \(formattedTime(locationData.timestamp))")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .frame(height: 300) // リストの高さを制限
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    // ローディングオーバーレイビュ-
    private var loadingOverlay: some View {
        ZStack {
            // 半透明の背景
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            // ローディングインジケータ
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.8))
                    .shadow(radius: 10)
            )
        }
        .transition(.opacity)
        .animation(.easeInOut, value: locationService.isRequestingLocation)
    }
    
    // 時刻をフォーマットするヘルパーメソッド
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}


#Preview {
    ContentView()
}
