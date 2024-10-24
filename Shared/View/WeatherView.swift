//
//  WeatherView.swift
//  Forecast
//

import SwiftUI
import Charts
import WeatherKit

struct WeatherView: View {
    @ObservedObject var viewModel = ViewModel()
    @Environment(\.colorScheme) private var colorScheme
    var searchResult: SearchResult
    var watchOS = false

    init(viewModel: ViewModel, searchResult: SearchResult) {
        self.searchResult = searchResult
        #if os(watchOS)
        watchOS = true
        #endif
        
        UserDefaults.standard.set(searchResult: searchResult)
    }
    
    fileprivate func lineMark(_ data: GraphData) -> some ChartContent {
        return LineMark(
            x: .value("date", data.date),
            y: .value("temperature", data.temperature.value),
            series: .value("series", data.series)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .foregroundStyle(Color.orange)
        .interpolationMethod(.catmullRom)
    }
    
    fileprivate func pointMark(_ data: GraphData) -> some ChartContent {
        return PointMark(
            x: .value("date", data.date),
            y: .value("temperature", data.temperature.value)
        )
        .foregroundStyle(Color.clear)
        .annotation(position: .overlay, content: {
            if !watchOS || (data.index % 2 == 0 && data.series == GraphData.Series.tempLow.rawValue) {
                ZStack {
                    Circle()
                        .fill(.background)
                        .frame(width: 22, height: 22)
                    Image(systemName: data.symbol)
                }
            }
        })
        .annotation(spacing: 10) {
            if !watchOS || (data.index % 2 == 0 && data.series == GraphData.Series.tempHigh.rawValue) {
                Text("\(Int(data.temperature.value))°")
                    .font(.caption)
            }
        }
    }
    
    var body: some View {
        Chart() {
            ForEach(viewModel.graphData, id: \.id) { data in
                lineMark(data)
                pointMark(data)
            }
        }
        .chartXAxis(content: {
            AxisMarks(values: .stride(by: .day)) { value in
                if !watchOS,
                   let date = value.as(Date.self)
                {
                    let weekday = Calendar.current.component(.weekday, from: date)
                    AxisValueLabel {
                        Text(viewModel.weekdayString(weekday: weekday))
                    }
                }
            }
        })
        .navigationTitle(searchResult.name)
        .padding()
        .overlay {
            WeatherOverlayView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.getForecast(searchResult: searchResult)
            viewModel.getAttribution(colorScheme: colorScheme)
        }
        #if !os(watchOS)
        .toolbar {
            ToolbarItem() {
                Button() {
                    viewModel.getForecast(searchResult: searchResult, useCache: false)
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        #endif
    }
}

#Preview {
    let day = TimeInterval(24 * 60 * 60)
    let searchResult = SearchResult(name: "Berlin", info: "")
    
    var result: [GraphData] = []
    result.append(GraphData(index: 0, date: Date(), day: 0, series: GraphData.Series.tempHigh.rawValue, temperature: .init(value: 10, unit: .celsius), symbol: "cloud.sun"))
    
    result.append(GraphData(index: 1, date: Date().addingTimeInterval(day), day: 1, series: GraphData.Series.tempHigh.rawValue, temperature: .init(value: 11, unit: .celsius), symbol: "cloud.sun"))
    
    result.append(GraphData(index: 2, date: Date().addingTimeInterval(day * 2), day: 2, series: GraphData.Series.tempHigh.rawValue, temperature: .init(value: 11, unit: .celsius), symbol: "cloud.sun"))

    result.append(GraphData(index: 0, date: Date(), day: 0, series: GraphData.Series.tempLow.rawValue, temperature: .init(value: 11, unit: .celsius), symbol: "cloud.sun"))
    
    result.append(GraphData(index: 1, date: Date().addingTimeInterval(day), day: 1, series: GraphData.Series.tempLow.rawValue,  temperature: .init(value: 13, unit: .celsius), symbol: "cloud.sun"))
    
    result.append(GraphData(index: 2, date: Date().addingTimeInterval(day * 2), day: 2, series: GraphData.Series.tempLow.rawValue,  temperature: .init(value: 12, unit: .celsius), symbol: "cloud.sun"))

    let viewModel = ViewModel()
    viewModel.graphData = result
    
    let weatherView = WeatherView(viewModel: viewModel, searchResult: searchResult)
    
    return weatherView
}
