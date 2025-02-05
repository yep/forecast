//
//  ContentViewModel.swift
//  Forecast
//

import SwiftUI
import MapKit

@MainActor @Observable
final class ViewModel: NSObject, ObservableObject {
    var weatherModel = WeatherModel()
    var navigationPath = NavigationPath()
    var searchSuggestions: [City] = []
    var cities: [City] = []
    var searchString = ""

    #if !os(watchOS)
    private let searchCompleter = MKLocalSearchCompleter()
    #endif

    override init() {
        super.init()
 
        #if !os(watchOS)
            searchCompleter.delegate = self
            searchCompleter.resultTypes = .address
        #endif
    }
    
    func onAppear() {
        updateCities()
        
        // restore last selected city
        if let selectedCity = UserDefaults.standard.selectedCity() {
            navigationPath.append(selectedCity)
        }
    }
    
    func updateCities() {
        cities = UserDefaults.standard.getCities()
    }
    
    func getSearchSuggestions() {
        #if !os(watchOS)
            searchCompleter.queryFragment = searchString
        #endif
    }
    
    func search() async {
        if searchString != "",
           let city = await weatherModel.getLocation(forAddress: searchString)
        {
            UserDefaults.standard.add(city: city)
            cities = UserDefaults.standard.getCities()
        }

        searchSuggestions = []
        searchString = ""
        #if !os(watchOS)
            searchCompleter.cancel()
        #endif
    }
    
    func delete(indexSet: IndexSet) {
        if let index = indexSet.first {
            UserDefaults.standard.delete(cityIndex: index)
            cities = UserDefaults.standard.getCities()
        }
    }
}

#if !os(watchOS)
extension ViewModel: @preconcurrency MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchSuggestions = []

        if completer.results.count == 1 {
            Task {
                let addressString = "\(completer.results[0].title), \(completer.results[0].subtitle)"
                if let city = await weatherModel.getLocation(forAddress: addressString) {
                    searchSuggestions.append(city)
                }
            }
        } else {
            for result in completer.results {
                searchSuggestions.append(City(name: result.title, info: result.subtitle))
            }
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        Logging.logger.log("did fail with error: \(error.localizedDescription)")
    }
}
#endif
