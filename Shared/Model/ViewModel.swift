//
//  ContentViewModel.swift
//  Forecast
//

import Foundation
import SwiftUI
import Charts
import CoreLocation
import WeatherKit

final class ViewModel: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var searchText = SearchResult()
    @Published var graphData: [GraphData] = []
    @Published var legalPageURL = URL(string: "")
    @Published var attributionLogoURL = URL(string: "")

    static let searchOnMapString = "Search on Map"
    private let dateFormatter = DateFormatter()
    private var forecasts: Forecast<DayWeather>?
    
    init() {
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = "dd"
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
                
        // restore last search result
        searchResults = UserDefaults.standard.getSearchResult()
    }
    
    func search() {
        searchResults = []
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(searchText.name) { (placemark: [CLPlacemark]?, error: Error?) in
            if let error {
                print(error)
            } else {
                var searchResult = SearchResult()
                for placemark in placemark ?? [] {
                    if let city = placemark.locality {
                        if let country = placemark.country {
                            searchResult = SearchResult(name: city, info: country)
                            searchResult.location = placemark.location
                        } else {
                            searchResult = SearchResult(name: city, info: "")
                        }
                    }
                }
                if searchResult.name != "" && searchResult.info != "" {
                    self.searchResults.append(searchResult)
                }
                // self.searchResults.append(SearchResult(name: Self.searchOnMapString, info: ""))
                self.objectWillChange.send()
            }
        }
    }
    
    func getForecast(searchResult: SearchResult, useCache: Bool = true) {
        guard let location = searchResult.location else {
            return
        }
        
        if let forecasts, useCache {
            print("using cache")
            self.handle(forecasts: forecasts)
        } else {
            Task { [weak self] in
                do {
                    let forecasts = try await WeatherService.shared.weather(for: location, including: .daily)
                    self?.forecasts = forecasts
                    self?.handle(forecasts: forecasts)
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
    
    func handle(forecasts: Forecast<DayWeather>) {
        var result: [GraphData] = []
        var i = 0

        for forecast in forecasts.forecast {
            let dateComponents = Calendar.current.dateComponents([.day], from: forecast.date)
            if let day = dateComponents.day {
                result.append(GraphData(index: i, date: forecast.date, day: day, series: GraphData.Series.tempHigh.rawValue, temperature: forecast.highTemperature, symbol: forecast.symbolName))
                result.append(GraphData(index: i, date: forecast.date, day: day, series: GraphData.Series.tempLow.rawValue, temperature: forecast.lowTemperature, symbol: forecast.symbolName))
            }
            i += 1
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.graphData = result
            self?.objectWillChange.send()
        }
    }
    
    func searchResultTitle(for searchResult: SearchResult) -> String {
        var text = searchResult.name
        if searchResult.info != "" {
            text = text.appending(" (\(searchResult.info))")
        }
        return text
    }
    
    func weekdayString(weekday: Int) -> String {
        return dateFormatter.shortWeekdaySymbols[weekday - 1]
    }
    
    func getAttribution(colorScheme: ColorScheme) {
        Task {
            do {
                let attribution = try await WeatherService.shared.attribution
                DispatchQueue.main.async {
                    self.legalPageURL = attribution.legalPageURL
                    self.attributionLogoURL = attribution.combinedMarkDarkURL
                    if colorScheme == .light {
                        self.attributionLogoURL = attribution.combinedMarkLightURL
                    }
                    self.objectWillChange.send()
                }
            } catch {
                print(error)
            }
        }
    }
}

