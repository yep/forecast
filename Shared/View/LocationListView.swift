//
//  LocationListView.swift
//  Forecast
//

import SwiftUI

struct LocationListView: View {
    @ObservedObject private var viewModel: ViewModel
    
    var body: some View {
        List() {
            if viewModel.cities.isEmpty {
                #if os(watchOS)
                Text("Please scroll up to add your first city")
                    .multilineTextAlignment(.center)
                #else
                Text("Please add your first city")
                    .multilineTextAlignment(.center)
                #endif
            } else {
                Section {
                    ForEach(viewModel.cities) { city in
                        NavigationLink(city.longName, value: city)
                    }
                    .onDelete { indexSet in
                        viewModel.delete(indexSet: indexSet)
                    }
                } header: {
                    Text("Cities")
                } footer: {
                    Text("Swipe left to delete city")
                }
            }
        }
        .navigationDestination(for: City.self) { city in
            WeatherView(weatherModel: WeatherModel(city: city))
        }
    }
    
    public init() {
        viewModel = ViewModel()
    }
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

#Preview {
    let viewModel = ViewModel()
    viewModel.cities = [City(name: "Berlin", info: "Deutschland"),
                        City(name: "Hamburg", info: "Deutschland")]
    return LocationListView(viewModel: viewModel)
    #if !os(watchOS)
        .frame(width: 300)
    #endif
}
