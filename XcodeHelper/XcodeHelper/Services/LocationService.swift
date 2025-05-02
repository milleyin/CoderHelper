//
//  LocationService.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/4/27.
//

import SwiftUI
import Combine
import CoreLocation

class LocationService: ObservableObject {
    
    static let shared = LocationService()
    
    ///当前位置(持续更新)
    @Published var location: CLLocation = .init()
    ///当前位置(单次更新)
    var currentLocation: CLLocation? {
        CoreLocationRepository.shared.currentLocation
    }
    ///方向
    @Published var direction: CLHeading = .init()
    
    
    private var subscriptions = Set<AnyCancellable>()
    
    private init() {
        updateLocation()
        updateDirection()
    }
    
    private func updateLocation() {
        CoreLocationRepository.shared.locationPublisher
            .compactMap({ $0 })
            .receive(on: RunLoop.main)
            .sink { [weak self] location in
                guard let self: LocationService else { return }
                self.location = location
            }.store(in: &self.subscriptions)
    }
    private func updateDirection() {
        CoreLocationRepository.shared.headingPublisher
            .compactMap({ $0 })
            .receive(on: RunLoop.main)
            .sink { [weak self] direction in
                self?.direction = direction
            }.store(in: &self.subscriptions)
            
    }
    deinit {
        self.subscriptions.forEach { $0.cancel() }
    }
    
    func allowBackgroundLocationUpdates(isAllowd: Bool) {
        CoreLocationRepository.shared.allowBackgroundLocationUpdates(isAllowd)
    }
}
