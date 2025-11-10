//
//  StringFormatter.swift
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

@MainActor struct StringFormatter {
    private static var weekdayFormatter: DateFormatter? = nil
    private static var timeFormatter:    DateFormatter? = nil

    static func weekdayString(date: Date) -> String {
        if weekdayFormatter == nil {
            weekdayFormatter = DateFormatter()
            weekdayFormatter?.calendar  = Calendar.current
            weekdayFormatter?.dateStyle = .none
            weekdayFormatter?.timeStyle = .none
        }

        let weekday = Calendar.current.component(.weekday, from: date)
        return weekdayFormatter?.shortWeekdaySymbols[weekday - 1] ?? ""
    }

    static func timeString(date: Date) -> String {
        if timeFormatter == nil {
            timeFormatter = DateFormatter()
            timeFormatter?.dateFormat = "HH:mm"
        }

        return timeFormatter?.string(from: date) ?? ""
    }
    
    static func temperatureString(_ tempererature: Measurement<UnitTemperature>) -> String {
        if tempererature.value.isNaN {
            return ""
        } else {
            return "\(Int(round(tempererature.value)))°"            
        }
    }
    
    static func precipitationString(_ precipitationIntensity: Measurement<UnitSpeed>) -> String {
        if precipitationIntensity.value.isNaN {
            return ""
        } else {
            return "\(Double(Int(precipitationIntensity.value * 10)) / 10)"
        }
    }
    
    static func fill(icon: String) -> String {
        let excludeList = ["wind", "wind.snow", "snowflake", "tornado", "tropicalstorm", "hurricane"]
        if excludeList.contains(icon) {
            return icon
        } else {
            return "\(icon).fill"
        }
    }
}
