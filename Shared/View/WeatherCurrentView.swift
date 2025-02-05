//
//  WeatherCurrentView.swift
//  Forecast
//

import SwiftUI
import Charts
import WeatherKit

struct WeatherCurrentView: View {
    @ObservedObject var weatherModel: WeatherModel

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
                Text(weatherModel.summary)
            }
        }
    }
}

#Preview {
    WeatherCurrentView(weatherModel: WeatherModel())
    .frame(width: 300, height: 50)
}
