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
extension WeatherCondition {
    var localizedDescription: String {
        switch self {
        case .blizzard: return "暴风雪"
        case .blowingDust: return "扬尘 / 沙尘暴"
        case .blowingSnow: return "吹雪"
        case .breezy: return "微风"
        case .clear: return "晴朗"
        case .cloudy: return "多云"
        case .drizzle: return "毛毛雨"
        case .flurries: return "零星小雪"
        case .foggy: return "有雾"
        case .freezingDrizzle: return "冻毛毛雨"
        case .freezingRain: return "冻雨"
        case .frigid: return "严寒"
        case .hail: return "冰雹"
        case .haze: return "霾"
        case .heavyRain: return "大雨"
        case .heavySnow: return "大雪"
        case .hot: return "炎热"
        case .hurricane: return "飓风"
        case .isolatedThunderstorms: return "局部雷暴"
        case .mostlyClear: return "大致晴朗"
        case .mostlyCloudy: return "大致多云"
        case .partlyCloudy: return "局部多云"
        case .rain: return "下雨"
        case .scatteredThunderstorms: return "零星雷暴"
        case .sleet: return "冻雨 / 雨夹雪"
        case .smoky: return "烟雾弥漫"
        case .snow: return "下雪"
        case .strongStorms: return "强雷暴"
        case .sunFlurries: return "日照雪"
        case .sunShowers: return "日照雨"
        case .thunderstorms: return "雷阵雨"
        case .tropicalStorm: return "热带风暴"
        case .windy: return "大风"
        case .wintryMix: return "冬季混合降水"
        @unknown default: return "未知天气"
        }
    }
}
