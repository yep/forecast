//
//  ContentViewModel.swift
//  Forecast
//

import Foundation
import SwiftUI
import Charts
import MapKit
@preconcurrency import WeatherKit

final class ViewModel: NSObject, ObservableObject {
    @Published var searchSuggestions: [City] = []
    @Published var cities: [City] = []
    @Published var searchString = ""
    @Published var graphData: [GraphData] = []
    @Published var legalPageURL = URL(string: "")
    @Published var attributionLogoURL = URL(string: "")

    var watchOS = false
#if !os(watchOS)
    private let searchCompleter = MKLocalSearchCompleter()
#endif
    private let dateFormatter = DateFormatter()
    private var forecasts: Forecast<DayWeather>?
    private var searchSubmitted = false
    
    override init() {
        super.init()
                
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = "dd"
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        #if os(watchOS)
            watchOS = true
        #else
            searchCompleter.delegate = self
            searchCompleter.resultTypes = .address
        #endif
    }
    
    func updateCities() {
        cities = UserDefaults.standard.getCities()
    }
    
    func getLocation(forAddress addressString: String, result: @escaping (City) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(addressString) { [weak self] (placemarks: [CLPlacemark]?, error: Error?) in
            if let error {
                print("error: get location for address failed: \(error.localizedDescription)")
            } else if let placemarks = placemarks {
                var searchResult: City
                for placemark in placemarks {
                    var name = ""
                    if let locality = placemark.locality {
                        name = locality
                    } else if let area = placemark.administrativeArea {
                        name = area
                    } else {
                        print("error: placemark has no locality and no administrative area: \(placemark)")
                        return
                    }
                    
                    searchResult = City(name: name, info: placemark.country ?? "")
                    searchResult.location = placemark.location

                    if name != "" && searchResult.info != "" {
                        result(searchResult)
                    }
                }
                self?.objectWillChange.send()
            }
        }
    }
    
    func getForecast(forCity city: City) {
        #if os(watchOS)
            getForecastAndLocation(for: city)
        #else
            if city.location != nil {
                getForecast(forLocation: city)
            } else {
                getForecastAndLocation(for: city)
            }
        #endif
    }
    
    fileprivate func getForecastAndLocation(for city: City) {
        getLocation(forAddress: city.longName) { (city: City) in
            self.getForecast(forLocation: city)
        }
    }

    func getForecast(forLocation city: City) {
        guard let location = city.location else {
            print("error: no location when getting forecast")
            return
        }
        
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
    
    func getSearchSuggestions() {
        #if !os(watchOS)
            if searchSubmitted {
                searchSubmitted = false
            } else {
                searchCompleter.queryFragment = searchString
            }
        #endif
    }
    
    func search() {
        if searchString != "" {
            getLocation(forAddress: searchString) { [weak self] (city: City) in
                UserDefaults.standard.add(city: city)
                self?.cities = UserDefaults.standard.getCities()
            }
        }
        searchSuggestions = []
        searchString = ""
        searchSubmitted = true
    }
    
    func delete(indexSet: IndexSet) {
        if let index = indexSet.first {
            UserDefaults.standard.deleteCity(at: index)            
        }
        cities = UserDefaults.standard.getCities()
    }
}

#if !os(watchOS)
extension ViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchSuggestions = []

        if completer.results.count == 1 {
            let addressString = "\(completer.results[0].title), \(completer.results[0].subtitle)"
            getLocation(forAddress: addressString) { [weak self] (city: City) in
                self?.searchSuggestions.append(city)
            }
        } else {
            for result in completer.results {
                searchSuggestions.append(City(name: result.title, info: result.subtitle))
            }
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        print("did fail with error: \(error.localizedDescription)")
    }
}
#endif
