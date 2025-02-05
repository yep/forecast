//
//  WeatherModel.swift
//  Forecast
//

import SwiftUI
import Charts
import MapKit
import Network
@preconcurrency import WeatherKit

@MainActor @Observable
final class WeatherModel: NSObject, ObservableObject {
    var city: City?
    var dailyGraphData: [GraphData] = []
    var houlyGraphData: [GraphData] = []
    var minutelyGraphData: [GraphData]?
    var currentWeather: CurrentWeather?
    var legalPageURL = URL(string: "")
    var attributionLogoURL = URL(string: "")
    var summary = ""

    override init() {
        super.init()
    }
    
    init(city: City) {
        self.city = city
        super.init()
    }
    
    func onAppear(colorScheme: ColorScheme) {
        guard let city else {
            Logging.logger.log("error: no color scheme when getting forecast")
            return
        }
        
        Task {
            await getForecast()
            await getAttribution(colorScheme: colorScheme)
        }
        UserDefaults.standard.set(selectedCity: city)
    }

    func getLocation(forAddress addressString: String) async -> City? {
        var searchResult: City?
        
        let geoCoder = CLGeocoder()
        do {
            let placemarks = try await geoCoder.geocodeAddressString(addressString)
            for placemark in placemarks {
                var name = ""
                if let locality = placemark.locality {
                    name = locality
                } else if let area = placemark.administrativeArea {
                    name = area
                } else {
                    Logging.logger.log("error: placemark has no locality and no administrative area: \(placemark)")
                    return nil
                }
                
                searchResult = City(name: name, info: placemark.country ?? "")
                searchResult?.location = placemark.location                
                self.objectWillChange.send()
            }
        } catch {
            Logging.logger.log("error: get location for address failed: \(error.localizedDescription)")
        }
        
        return searchResult
    }
    
    func getForecast() async {
        guard let city else {
            Logging.logger.log("error: no city when getting forecast")
            return
        }
        currentWeather = nil
        
        #if os(watchOS)
            await getForecastAndLocation(for: city)
        #else
            if city.location != nil {
                await getForecast(forLocation: city)
            } else {
                await getForecastAndLocation(for: city)
            }
        #endif
    }

    func handle(dailyForecasts: Forecast<DayWeather>) {
        dailyGraphData = []
        for forecast in dailyForecasts.forecast {
            dailyGraphData.append(GraphData(date: forecast.date, series: GraphData.Series.temperatureHigh.rawValue, temperature: forecast.highTemperature, symbol: forecast.symbolName))
            dailyGraphData.append(GraphData(date: forecast.date, series: GraphData.Series.temperatureLow.rawValue, temperature: forecast.lowTemperature, symbol: forecast.symbolName))
        }
    }

    func handle(hourlyForecasts: Forecast<HourWeather>) {
        houlyGraphData = []
        for forecast in hourlyForecasts.forecast {
            houlyGraphData.append(GraphData(date: forecast.date, series: GraphData.Series.temperatureHigh.rawValue, temperature: forecast.temperature, symbol: forecast.symbolName))
        }
    }
    
    func handle(minuteForecasts: Forecast<MinuteWeather>?) {
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
                minutelyGraphData?.append(GraphData(date: forecast.date, series: GraphData.Series.precipitation.rawValue, precipitation: forecast.precipitationIntensity, symbol: symbol))
            }
        }
    }
    
    func handle(currentWeather: CurrentWeather) {
        self.currentWeather = currentWeather
    }

    func getAttribution(colorScheme: ColorScheme) async {
        do {
            let attribution = try await WeatherService.shared.attribution
            self.legalPageURL = attribution.legalPageURL
            self.attributionLogoURL = attribution.combinedMarkDarkURL
            if colorScheme == .light {
                self.attributionLogoURL = attribution.combinedMarkLightURL
            }
            self.objectWillChange.send()
        } catch {
            Logging.logger.log("error when getting attribution: \(error)")
        }
    }
    
    // MARK: - Private
    
    fileprivate func getForecastAndLocation(for city: City) async {
        if let city = await getLocation(forAddress: city.longName) {
            await self.getForecast(forLocation: city)
        }
    }

    func getForecast(forLocation city: City) async {
        guard let location = city.location else {
            Logging.logger.log("error: no location when getting forecast")
            return
        }
        
        do {
            handle(dailyForecasts:  try await WeatherService.shared.weather(for: location, including: .daily))
            handle(hourlyForecasts: try await WeatherService.shared.weather(for: location, including: .hourly))
            handle(minuteForecasts: try await WeatherService.shared.weather(for: location, including: .minute))
            handle(currentWeather:  try await WeatherService.shared.weather(for: location, including: .current))
        } catch {
            Logging.logger.log("error when getting forecast: \(error)")
        }
    }
}
