//
//  GraphData.swift
//  Forecast
//

import Foundation
import WeatherKit

struct GraphData: Identifiable {
    enum Series: String {
        case temperatureHigh = "temperature high"
        case temperatureLow  = "temperature low"
        case precipitation   = "precipitation"
    }
    
    var id: TimeInterval {
        get {
            date.timeIntervalSinceReferenceDate
        }
    }
    var date: Date
    var series: String // temperatureHigh or temperatureLow
    var temperature: Measurement<UnitTemperature> = .init(value: .infinity, unit: .celsius)
    var precipitation: Measurement<UnitSpeed> = .init(value: .infinity, unit: .kilometersPerHour)
    var symbol = ""
}
