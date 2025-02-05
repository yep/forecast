//
//  StringFormatter.swift
//  Forecast
//

import Foundation

@MainActor struct StringFormatter {
    private static var weekdayFormatter: DateFormatter? = nil
    private static var timeFormatter:    DateFormatter? = nil

    static func weekdayString(date: Date) -> String {
        if weekdayFormatter == nil {
            weekdayFormatter = DateFormatter()
            weekdayFormatter?.calendar   = Calendar.current
            weekdayFormatter?.dateFormat = "dd"
            weekdayFormatter?.dateStyle  = .short
            weekdayFormatter?.timeStyle  = .none
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
    
    static func precipitationString(_ precipitationIntensity: Measurement<UnitSpeed>) -> String {
        return "\(Double(Int(precipitationIntensity.value * 10)) / 10)"
    }
}
