//
//  WeatherAttributionView.swift
//  Forecast
//

import SwiftUI
import WeatherKit

struct WeatherAttributionView: View {
    @ObservedObject private var weatherModel = WeatherModel()
    
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
