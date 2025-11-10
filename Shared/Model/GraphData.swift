//
//  GraphData.swift
//  Forecast - Graphical weather forecast for the next 10 days
//  Copyright (C) 2025 Jahn Bertsch
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import WeatherKit

struct GraphData: Identifiable {
    var id: TimeInterval {
        get {
            date.timeIntervalSinceReferenceDate
        }
    }
    var date: Date
    var temperatureLow: Measurement<UnitTemperature> = .init(value: .nan, unit: .init(forLocale: Locale.current))
    var temperatureHigh: Measurement<UnitTemperature> = .init(value: .nan, unit: .init(forLocale: Locale.current))
    var precipitation: Measurement<UnitSpeed> = .init(value: .nan, unit: .init(forLocale: Locale.current))
    var symbol = ""
    private static let dayTimeInterval = TimeInterval(24 * 60 * 60)

    static func placeholderData() -> [GraphData] {
        var result: [GraphData] = []
        result.append(placeholderData(day: 0, low: 5, high: 14, symbol: "cloud.sun"))
        result.append(placeholderData(day: 1, low: 4, high: 12, symbol: "cloud.sun"))
        result.append(placeholderData(day: 2, low: 3, high: 10, symbol: "sun.max"))
        result.append(placeholderData(day: 3, low: 3, high: 10, symbol: "cloud.sun"))
        result.append(placeholderData(day: 4, low: 4, high: 11, symbol: "sun.max"))
        result.append(placeholderData(day: 5, low: 4, high: 12, symbol: "sun.max"))
        return result
    }
    
    fileprivate static func placeholderData(day: Int, low: Int, high: Int, symbol: String) -> GraphData {
        let today = Calendar.current.startOfDay(for: Date())
        let date = today.addingTimeInterval(Self.dayTimeInterval * Double(day))
        return GraphData(date: date, temperatureLow:  .init(value: Double(low), unit: .init(forLocale: Locale.current)), temperatureHigh: .init(value: Double(high), unit: .init(forLocale: Locale.current)), symbol: symbol)
    }
}

extension GraphData: Comparable {
    static func < (lhs: GraphData, rhs: GraphData) -> Bool {
        lhs.temperatureHigh < rhs.temperatureHigh
    }
}
