//
//  WeatherCurrentView.swift
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
import Charts
import WeatherKit

struct WeatherCurrentView: View {
    var weatherModel: WeatherModel

    init(weatherModel: WeatherModel) {
        self.weatherModel = weatherModel
   }
        
    var body: some View {
        HStack(alignment: .center) {
            if weatherModel.currentWeather == nil {
                Text("")
            } else {
                Text("\(weatherModel.currentWeather?.temperature.formatted(WeatherView.measurementFormatStyle) ?? "")")
                Image(systemName: weatherModel.currentWeather?.symbolName ?? "")
                if let precipitationIntensity = weatherModel.currentWeather?.precipitationIntensity,
                   precipitationIntensity.value != 0
                {
                    Text("\(StringFormatter.precipitationString(precipitationIntensity)) \(precipitationIntensity.unit.symbol) Rain")
                } else {
                    Text(" No Rain")
                }
            }
        }.onTapGesture {
            Task {
                await weatherModel.getForecast()                
            }
        }
    }
}

#Preview {
    WeatherCurrentView(weatherModel: WeatherModel())
    .frame(width: 300, height: 50)
}
