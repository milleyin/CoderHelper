//
//  WeatherManager.swift
//  XcodeHelper
//
//  Created by Mille Yin on 2025/4/27.
//

import Foundation
import WeatherKit
import CoreLocation
import CoreLocationKit

@MainActor
class WeatherManager: ObservableObject {
    
    private let weatherService = WeatherService()
    ///当前气温
    @Published var currentWeather: CurrentWeather?
    ///当天气温
    @Published var dailyWeather: DayWeather?
    ///错误信息
    @Published var errorMessage: String?
    
    init() {
        CoreLocationKit.shared.requestCurrentLocation()
        Task {
            if let location = CoreLocationKit.shared.currentLocation {
                await fetchWeather(for: location)
            }
        }
    }
    
    func fetchWeather(for location: CLLocation) async {
        do {
            let weather = try await weatherService.weather(for: location)
            self.currentWeather = weather.currentWeather
            if let dailyForecast = weather.dailyForecast.first {
                self.dailyWeather = dailyForecast
            }
        } catch {
            self.errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
        }
    }
}
