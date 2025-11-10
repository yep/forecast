//
//  SearchSuggestionsView.swift
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

struct LocationSuggestionsView: View {
    @Bindable private var viewModel: ViewModel
    @Environment(\.dismissSearch) private var dismissSearch

    var body: some View {
        List() {
            ForEach($viewModel.searchSuggestions) { city in
                Text(city.wrappedValue.longName)
                .frame(minHeight: 30)
                .onTapGesture {
                    dismissSearch()
                    Task() {
                        viewModel.searchString = city.wrappedValue.longName
                        await viewModel.search()
                    }
                }
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
    viewModel.searchSuggestions = [City(name: "München", info: "Deutschland"),
                                   City(name: "Köln", info: "Deutschland")]
    return LocationView(viewModel: viewModel)
    #if !os(watchOS)
    .frame(width: 300)
    #endif
}
