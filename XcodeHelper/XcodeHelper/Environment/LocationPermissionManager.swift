//
//  LocationPermissionManager.swift
//  XcodeHelper
//
//  Created by mille on 2025/4/12.
//

import Foundation
import CoreLocation
import AppKit

class LocationPermissionManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestAccessIfNeeded() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation() // 必须要调起才生效
        case .denied:
            // 引导用户手动打开定位权限
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices")!)
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation() // 我们只是借用权限，不需要持续定位
    }
}
