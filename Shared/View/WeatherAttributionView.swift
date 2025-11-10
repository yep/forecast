//
//  WeatherAttributionView.swift
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
import WeatherKit

struct WeatherAttributionView: View {
    private var weatherModel = WeatherModel()
    
    init(weatherModel: WeatherModel) {
        self.weatherModel = weatherModel
    }
    
    var body: some View {
        if let legalPageURL = weatherModel.legalPageURL {
            VStack {
                Link(destination: legalPageURL) {
                    AsyncImage(url: weatherModel.attributionLogoURL, scale: 4.0)
                }
                .foregroundStyle(.clear)
                .frame(width: 50)

                Link(destination: legalPageURL) {
                    Text("Other data sources")
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.foreground)
                .font(.system(size: 12, weight: .light))
            }
        }
    }
}

#Preview {
    WeatherAttributionView(weatherModel: WeatherModel())
}
