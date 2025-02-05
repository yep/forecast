//
//  WeatherView.swift
//  Forecast
//

import SwiftUI
import Charts
import WeatherKit

struct WeatherView: View {
    @ObservedObject var weatherModel = WeatherModel()
    static var measurementFormatStyle = Measurement.FormatStyle()

    @Environment(\.colorScheme) private var colorScheme

    init(weatherModel: WeatherModel) {
        self.weatherModel = weatherModel
        Self.measurementFormatStyle.numberFormatStyle = .number.precision(.integerAndFractionLength(integerLimits: 1...2, fractionLimits: 0...0))
        Self.measurementFormatStyle.hidesScaleName = true
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            List() {
                Section("Current Weather") {
                    if weatherModel.currentWeather == nil {
                        Text("Loading, please wait...")
                    } else {
                        WeatherCurrentView(weatherModel: weatherModel)
                    }
                }
                
                if weatherModel.currentWeather != nil {
                    Section("Daily Forecast") {
                        WeatherScrollView() {
                            WeatherGraphView(weatherModel: weatherModel, kind: .daily, geometryProxy: geometryProxy)
                        }
                        .frame(width: width(for: geometryProxy), height: height(for: geometryProxy))
                    }
                    
                    Section("Hourly Forecast") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            WeatherGraphView(weatherModel: weatherModel, kind: .hourly, geometryProxy: geometryProxy)
                        }
                        .frame(width: width(for: geometryProxy), height: height(for: geometryProxy))
                    }
                    
                    if let minutelyGraphData = weatherModel.minutelyGraphData,
                       let unitSymbol = minutelyGraphData.first?.precipitation.unit.symbol
                    {
                        Section("Rain Forecast (\(unitSymbol))") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                WeatherGraphView(weatherModel: weatherModel, kind: .minutely, geometryProxy: geometryProxy)
                            }
                            .frame(width: width(for: geometryProxy), height: height(for: geometryProxy))
                        }
                    }
                    
                    Section() {
                        WeatherAttributionView(weatherModel: weatherModel)
                        .frame(width: width(for: geometryProxy), height: 30)
                    }
                }
            }
        }
        .navigationTitle(weatherModel.city?.name ?? "")
        .onAppear {
            weatherModel.onAppear(colorScheme: colorScheme)
        }
        #if !os(watchOS)
        .toolbar {
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
        #endif
    }
    
    // MARK: - Private
    
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
