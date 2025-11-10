//
//  LocationView.swift
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

struct LocationView: View {
    @Bindable private var viewModel: ViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            HStack {
                if !viewModel.searchSuggestions.isEmpty {
                    LocationSuggestionsView(viewModel: viewModel)
                } else {
                    LocationListView(viewModel: viewModel)
                }
            }
            #if !os(watchOS)
            .searchable(text: $viewModel.searchString, placement: .automatic, prompt: "Add city")
            #endif
        }
        .navigationTitle("Forecast")
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear() {
            viewModel.updateCities()
        }
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
