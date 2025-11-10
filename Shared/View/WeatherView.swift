//
//  WeatherView.swift
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

struct WeatherView: View {
    var weatherModel = WeatherModel()
    static var measurementFormatStyle = Measurement.FormatStyle()

    @Environment(\.colorScheme) private var colorScheme

    init(weatherModel: WeatherModel) {
        self.weatherModel = weatherModel
        Self.measurementFormatStyle.numberFormatStyle = .number.precision(.significantDigits(2))
        Self.measurementFormatStyle.hidesScaleName = true
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            List() {
                currentWeather()
                
                if weatherModel.currentWeather != nil {
                    dailyForecast(geometryProxy: geometryProxy)
                    hourlyForecast(geometryProxy: geometryProxy)
                    
                    if let minutelyGraphData = weatherModel.minutelyGraphData,
                       let unitSymbol = minutelyGraphData.first?.precipitation.unit.symbol
                    {
                        rainForecast(geometryProxy: geometryProxy, unitSymbol: unitSymbol)
                    }
                    
                    #if os(watchOS)
                    reloadButton(geometryProxy: geometryProxy)
                    #endif
                    
                    attributionView(geometryProxy: geometryProxy)
                }
            }
        }
        .navigationTitle(weatherModel.city?.name ?? "")
        .onAppear {
            weatherModel.onAppear(colorScheme: colorScheme)
        }
        .toolbar {
            toolbarItem()
        }
    }
    
    // MARK: - Private

    fileprivate func currentWeather() -> some View {
        Section("Current Weather") {
            if weatherModel.currentWeather == nil {
                Text("Loading, please wait...")
            } else {
                WeatherCurrentView(weatherModel: weatherModel)
            }
        }
    }
    
    fileprivate func dailyForecast(geometryProxy: GeometryProxy) -> some View {
        Section("Daily Forecast") {
            WeatherScrollView() {
                WeatherGraphView(weatherModel: weatherModel, kind: .daily, geometryProxy: geometryProxy)
            }
            .frame(width: width(for: geometryProxy), height: height(for: geometryProxy))
        }
    }
    
    fileprivate func hourlyForecast(geometryProxy: GeometryProxy) -> some View {
        Section("Hourly Forecast") {
            ScrollView(.horizontal, showsIndicators: false) {
                WeatherGraphView(weatherModel: weatherModel, kind: .hourly, geometryProxy: geometryProxy)
            }
            .frame(width: width(for: geometryProxy), height: height(for: geometryProxy))
        }
    }
    
    fileprivate func rainForecast(geometryProxy: GeometryProxy, unitSymbol: String) -> some View {
        Section("Rain Forecast (\(unitSymbol))") {
            ScrollView(.horizontal, showsIndicators: false) {
                WeatherGraphView(weatherModel: weatherModel, kind: .minutely, geometryProxy: geometryProxy)
            }
            .frame(width: width(for: geometryProxy), height: height(for: geometryProxy))
        }
    }
    
    fileprivate func reloadButton(geometryProxy: GeometryProxy) -> some View {
        Section() {
            Button {
                Task {
                    await weatherModel.getForecast()
                }
            } label: {
                Text("Reload")
                    .frame(width: width(for: geometryProxy), height: 30)
            }
        }
    }
    
    fileprivate func attributionView(geometryProxy: GeometryProxy) -> some View {
        return Section() {
            WeatherAttributionView(weatherModel: weatherModel)
                .frame(width: width(for: geometryProxy), height: 30)
        }
    }
    
    fileprivate func toolbarItem() -> ToolbarItem<(), Button<Image>> {
        ToolbarItem() {
            Button() {
                Task {
                    await weatherModel.getForecast()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
    }

    fileprivate func width(for geometryProxy: GeometryProxy) -> CGFloat {
        #if os(watchOS)
            return geometryProxy.size.width - 20
        #else
            return geometryProxy.size.width - 40
        #endif
    }
    
    fileprivate func height(for geometryProxy: GeometryProxy) -> CGFloat {
        #if os(watchOS)
            return geometryProxy.size.height
        #else
            return geometryProxy.size.height * 0.4
        #endif
    }
}

#Preview {
    let weatherModel = WeatherModel(city: City(name: "Berlin"))
    let navigationView = NavigationView {
        WeatherView(weatherModel: weatherModel)
    }
    #if os(macOS)
    .frame(width: 300)
    #endif
    
    return navigationView
}
