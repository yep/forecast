//
//  LocationView.swift
//  Forecast
//

import SwiftUI

struct LocationView: View {
    @ObservedObject private var viewModel: ViewModel
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            LocationListView(viewModel: viewModel)
            .searchable(text: $viewModel.searchString, prompt: "Add city") {
                ForEach($viewModel.searchSuggestions) { city in
                    Text(city.wrappedValue.longName)
                        .lineLimit(0)
                        .searchCompletion(city.wrappedValue.longName)
                }
                .tint(Color.primary)
            }
            .searchSuggestions(.automatic, for: .content)
            .onChange(of: viewModel.searchString) {
                viewModel.getSearchSuggestions()
            }
            .onSubmit(of: .search) {
                let viewModel = viewModel
                Task {
                    await viewModel.search()
                }
            }
        }
        .navigationTitle("Forecast")
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear() {
            viewModel.updateCities()
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
    viewModel.cities = [City(name: "Berlin", info: "Deutschland")]
    return LocationView(viewModel: viewModel)
    #if !os(watchOS)
        .frame(width: 300)
    #endif
}
