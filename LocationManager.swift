//
//  LocationManager.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/15.
//
import SwiftUI
import MapKit
import Firebase
import CoreLocation

//MARK: - 位置情報に関するイベントをコントロール
final class LocationManager: NSObject,ObservableObject,MKMapViewDelegate,CLLocationManagerDelegate{
    
    static let shared = LocationManager()
    let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D = .userLocation
    @Published var isLocationAuthorized : Bool = false
    @Published var lastLocation: CLLocation?

    override init(){
        
        super.init()
        manager.delegate = self                                 // デリゲート先が同じ
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest       // 位置精度
        manager.distanceFilter = 1                            // 更新頻度、距離
        manager.startUpdatingLocation()                         // 追跡をスタートさせるメソッド
        manager.pausesLocationUpdatesAutomatically = false      // 自動OFFしない
        manager.activityType = .fitness                         // 徒歩で移動
        

    }
    
    
    //MARK: - 位置情報を取得した場合以下の、関数を呼び出し緯度経度等の情報を取得できます。
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        
        userLocation = lastLocation.coordinate
        
        self.lastLocation = lastLocation
        isLocationAuthorized = true

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    
    //MARK: - プライバシー変更有無確認
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization()
    }
    
    private func checkAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            isLocationAuthorized = false
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationAuthorized = true
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
}


//MARK: - 初期位置を定義
extension CLLocationCoordinate2D{
    static var userLocation: CLLocationCoordinate2D{
        return.init(latitude: 33.76732853351689,
                    longitude: -116.35441365726726)
    }
}

//MARK: - 表示領域を定義
extension MKCoordinateRegion{
    static var userRegion:MKCoordinateRegion{
        return .init(center: .userLocation,
                     latitudinalMeters: 30,
                     longitudinalMeters: 30)
    }
}
