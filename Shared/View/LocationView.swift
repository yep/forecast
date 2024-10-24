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
                List($viewModel.searchResults) { searchResult in
                    if searchResult.location.wrappedValue != nil {
                        let searchResultTitle = viewModel.searchResultTitle(for: searchResult.wrappedValue)
                        
                        NavigationLink(searchResultTitle) {
                            WeatherView(viewModel: ViewModel(), searchResult: searchResult.wrappedValue)
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText.name)
            .onSubmit(of: .search) {
                viewModel.search()
            }
            .navigationTitle("Search City")
        }
    }
    
    public init() {}
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}

#Preview {
    let viewModel = ViewModel()
    viewModel.searchResults = [SearchResult(name: "Berlin", info: "Deutschland")]
    return LocationView(viewModel: viewModel)
}

