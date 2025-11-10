//
//  ViewModel.swift
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
import MapKit

@MainActor @Observable
final class ViewModel: NSObject, ObservableObject {
    var weatherModel = WeatherModel()
    var navigationPath = NavigationPath()
    var searchSuggestions: [City] = []
    var cities: [City] = []
    var searchString = ""

    private let searchCompleter = MKLocalSearchCompleter()

    override init() {
        super.init() 
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    func onAppear() {
        updateCities()
        
        // restore last selected city
        if let selectedCity = UserDefaults.appGroup.selectedCity() {
            navigationPath.append(selectedCity)
        }
    }
    
    func updateCities() {
        cities = UserDefaults.appGroup.getCities()
    }
    
    func getSearchSuggestions() {
        searchCompleter.queryFragment = searchString.trimmingCharacters(in: .whitespaces)
    }
    
    func search() async {
        if searchString != "",
           let city = await weatherModel.getLocation(forAddress: searchString)
        {
            UserDefaults.appGroup.add(city: city)
            cities = UserDefaults.appGroup.getCities()
        }

        searchSuggestions = []
        searchString = ""
        searchCompleter.cancel()
    }
    
    func delete(indexSet: IndexSet) {
        if let index = indexSet.first {
            UserDefaults.appGroup.delete(cityIndex: index)
            cities = UserDefaults.appGroup.getCities()
        }
    }
}

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
        Logging.logger.log("search completer did fail with error: \(error.localizedDescription)")
    }
}
