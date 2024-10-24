//
//  GraphData.swift
//  Forecast
//

import Foundation

struct GraphData: Identifiable {
    enum Series: String {
        case tempHigh = "temp high"
        case tempLow = "temp low"
    }
    
    var id: TimeInterval {
        get {
            date.timeIntervalSinceReferenceDate
        }
    }
    var index: Int
    var date: Date
    var day: Int
    var series: String // tempMin or tempMax
    var temperature: Measurement<UnitTemperature>
    var symbol: String
}
