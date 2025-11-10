//
//  WeatherModel.swift
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

import SwiftUI
import Charts
@preconcurrency import MapKit
@preconcurrency import WeatherKit

@MainActor @Observable final class WeatherModel: NSObject {
    var city: City?
    var dailyGraphData: [GraphData] = []
    var houlyGraphData: [GraphData] = []
    var minutelyGraphData: [GraphData]?
    var currentWeather: CurrentWeather?
    var legalPageURL = URL(string: "")
    var attributionLogoURL = URL(string: "")

    private var daysToDisplay: Int
    private static let currentTemperatureUnit = UnitTemperature.init(forLocale: Locale.current)

    override init() {
        daysToDisplay = Int.max
        super.init()
    }
    
    init(city: City, daysToDisplay: Int? = nil) {
        self.city = city
        self.daysToDisplay = daysToDisplay ?? Int.max
        super.init()
    }
    
    func onAppear(colorScheme: ColorScheme) {
        guard let city else {
            Logging.logger.log("error: no color scheme when getting forecast")
            return
        }
        UserDefaults.appGroup.set(selectedCity: city)

        Task {
            _ = await getForecast()
            await getAttribution(colorScheme: colorScheme)
        }
    }

    func getLocation(forAddress addressString: String) async -> City? {
        var searchResult: City? = nil
        guard let geocodingRequest = MKGeocodingRequest(addressString: addressString) else {
            Logging.logger.log("error: no address string provided")
            return nil
        }
        
        do {
            let mapItems = try await geocodingRequest.mapItems
                        
            for mapItem in mapItems {
                var name = ""
                if let locality = mapItem.placemark.locality {
                    name = locality
                } else if let area = mapItem.placemark.administrativeArea {
                    name = area
                } else {
                    Logging.logger.log("error: placemark has no locality and no administrative area: \(mapItem)")
                    return nil
                }
                
                searchResult = City(name: name, info: mapItem.placemark.country ?? "")
                searchResult?.location = mapItem.location                
            }
            print()
        } catch {
            Logging.logger.log("error: get location for address failed: \(error.localizedDescription)")
        }
        
        return searchResult
    }
    
    func getForecast(dailyForecastOnly: Bool = false) async -> Error? {
        guard let city else {
            Logging.logger.log("error: no city when getting forecast")
            return nil
        }
        currentWeather = nil
        
        #if os(watchOS)
            return await getForecastAndLocation(for: city, dailyForecastOnly: dailyForecastOnly)
        #else
            if city.location != nil {
                return await getForecast(forLocation: city)
            } else {
                return await getForecastAndLocation(for: city, dailyForecastOnly: dailyForecastOnly)
            }
        #endif
    }
    
    // MARK: - Private
    
    fileprivate func getForecastAndLocation(for city: City, dailyForecastOnly: Bool = false) async -> Error? {
        if let city = await getLocation(forAddress: city.longName) {
            return await self.getForecast(forLocation: city, dailyForecastOnly: dailyForecastOnly)
        }
        return nil
    }

    fileprivate func getForecast(forLocation city: City, dailyForecastOnly: Bool = false) async -> Error? {
        guard let location = city.location else {
            Logging.logger.log("error: no location when getting forecast")
            return nil
        }
        
        do {
            handle(dailyForecasts:  try await WeatherService.shared.weather(for: location, including: .daily))
            if !dailyForecastOnly {
                handle(hourlyForecasts: try await WeatherService.shared.weather(for: location, including: .hourly))
                handle(minuteForecasts: try await WeatherService.shared.weather(for: location, including: .minute))
                handle(currentWeather:  try await WeatherService.shared.weather(for: location, including: .current))
            }
        } catch {
            Logging.logger.log("error when getting forecast: \(error)")
            return error
        }
        
        return nil
    }

    fileprivate func getAttribution(colorScheme: ColorScheme) async {
        do {
            let attribution = try await WeatherService.shared.attribution
            self.legalPageURL = attribution.legalPageURL
            self.attributionLogoURL = attribution.combinedMarkDarkURL
            if colorScheme == .light {
                self.attributionLogoURL = attribution.combinedMarkLightURL
            }
        } catch {
            Logging.logger.log("error when getting attribution: \(error)")
        }
    }

    fileprivate func handle(dailyForecasts: Forecast<DayWeather>) {
        dailyGraphData = []
        for i in 0 ..< min(dailyForecasts.forecast.count, daysToDisplay) {
            let forecast = dailyForecasts.forecast[i]
            dailyGraphData.append(GraphData(date: forecast.date, temperatureLow: forecast.lowTemperature.converted(to: Self.currentTemperatureUnit), temperatureHigh: forecast.highTemperature.converted(to: Self.currentTemperatureUnit), symbol: forecast.symbolName))
        }
    }

    fileprivate func handle(hourlyForecasts: Forecast<HourWeather>) {
        houlyGraphData = []
        for forecast in hourlyForecasts.forecast {
            houlyGraphData.append(GraphData(date: forecast.date, temperatureHigh: forecast.temperature.converted(to: Self.currentTemperatureUnit), symbol: forecast.symbolName))
        }
    }
    
    fileprivate func handle(minuteForecasts: Forecast<MinuteWeather>?) {
        if let minuteForecasts {
            minutelyGraphData = []
            for forecast in minuteForecasts.forecast {
                var symbol: String
                if forecast.precipitation == .snow {
                    symbol = "cloud.snow"
                } else {
                    if forecast.precipitationIntensity.unit.symbol == UnitSpeed.init(symbol: "mm/h").symbol {
                        switch forecast.precipitationIntensity.value {
                        case 0:
                            symbol = "cloud"
                        case 0 ..< 4:
                            symbol = "cloud.drizzle"
                        case 4 ..< 8:
                            symbol = "cloud.rain"
                        default:
                            symbol = "cloud.heavyrain"
                        }
                    } else {
                        symbol = "cloud.rain"
                    }
                }
                minutelyGraphData?.append(GraphData(date: forecast.date, precipitation: forecast.precipitationIntensity, symbol: symbol))
            }
        }
    }
    
    fileprivate func handle(currentWeather: CurrentWeather) {
        self.currentWeather = currentWeather
    }
}
