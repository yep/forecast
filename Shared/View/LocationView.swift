//
//  LocationView.swift
//  Forecast
//

import SwiftUI

struct LocationView: View {
    @ObservedObject private var viewModel = ViewModel()
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                #if os(watchOS)
                if !isSearching {
                    Text(" ") // otherwise search field is not shown on watch osw
                }
                #endif
                
                List() {
                    if viewModel.cities.isEmpty {
                        Text("Please search for your first city")
                            .multilineTextAlignment(.center)
                    } else {
                        if !viewModel.cities.isEmpty {
                            Section {
                                ForEach($viewModel.cities) { city in
                                    let city = city.wrappedValue
                                    NavigationLink(city.longName) {
                                        WeatherView(viewModel: viewModel, city: city)
                                    }
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
                }
                .searchable(text: $viewModel.searchString, prompt: "Enter city") {
                    ForEach($viewModel.searchSuggestions) { city in
                        Text(city.wrappedValue.longName)
                            .lineLimit(0)
                            .searchCompletion(city.wrappedValue.longName)
                    }
                    .tint(Color.primary)
                    .searchSuggestions(.automatic, for: .content)
                }
                .onChange(of: viewModel.searchString) {
                    viewModel.getSearchSuggestions()
                }
                .onSubmit(of: .search) {
                    viewModel.search()
                }
            }
        }
        .navigationTitle("Forecast")
        .onAppear {
            viewModel.updateCities()
        }
        .onDisappear() {
            viewModel.updateCities()
        }
    }
    
    public init() {}
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

#Preview {
    let viewModel = ViewModel()
    viewModel.cities = [City(name: "Berlin", info: "Deutschland")]
    return LocationView(viewModel: viewModel).frame(width: 300)
}
