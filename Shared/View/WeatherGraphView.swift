//
//  WeatherView.swift
//  Forecast
//

import SwiftUI
import Charts
import WeatherKit

struct WeatherGraphView: View {
    enum Kind {
        case daily
        case hourly
        case minutely
    }
    var weatherModel: WeatherModel
    private let geometryProxy: GeometryProxy
    private let kind: Kind
    private var fullWidth: Bool
    private static let day = TimeInterval(24 * 60 * 60)

    init(weatherModel: WeatherModel, kind: Kind, geometryProxy: GeometryProxy, placeholder: Bool = false, fullWidth: Bool = false) {
        self.weatherModel = weatherModel
        self.geometryProxy = geometryProxy
        self.kind = kind
        self.fullWidth = fullWidth

        if placeholder {
            insertPlaceholderData()
        }
    }
    
    func insertPlaceholderData() {
        var graphData: [GraphData] = []
        graphData.append(placeholderData(day: 0, series: .temperatureHigh, value: 11))
        graphData.append(placeholderData(day: 1, series: .temperatureHigh, value: 6))
        graphData.append(placeholderData(day: 2, series: .temperatureHigh, value: 9))
        graphData.append(placeholderData(day: 0, series: .temperatureLow,  value: 7))
        graphData.append(placeholderData(day: 1, series: .temperatureLow,  value: 5))
        graphData.append(placeholderData(day: 2, series: .temperatureLow,  value: 7))
        weatherModel.houlyGraphData = graphData
        weatherModel.dailyGraphData = graphData
    }

    var body: some View {
        Chart() {
            ForEach(graphData(), id: \.id) { data in
                lineMark(for: data)
                pointMark(for: data)
            }
        }
        .frame(width: frameWidth())
        .chartXAxis(content: {
            AxisMarks(values: axisMarksStride()) { axisValue in
                if let date = axisValue.as(Date.self) {
                    AxisValueLabel {
                        if kind == .daily {
                            Text(StringFormatter.weekdayString(date: date))
                        } else if kind == .hourly {
                            Text("\(Calendar.current.component(.hour, from: date))")
                        } else {
                            Text(StringFormatter.timeString(date: date))
                        }
                    }
                }
            }
        })
    }
    
    // MARK: - Private
    
    fileprivate func lineMark(for graphData: GraphData) -> some ChartContent {
        var value = graphData.temperature.value
        if kind == .minutely {
            value = graphData.precipitation.value
        }
        
        return LineMark(
            x: .value("date", graphData.date),
            y: .value("value", value),
            series: .value("series", graphData.series)
        )
        .foregroundStyle(Color.orange)
        .interpolationMethod(.catmullRom)
    }
    
    fileprivate func pointMark(for graphData: GraphData) -> some ChartContent {
        var value = graphData.temperature.value
        var annotation = graphData.temperature.formatted(WeatherView.measurementFormatStyle)
        if kind == .minutely {
            value = graphData.precipitation.value
            annotation = StringFormatter.precipitationString(graphData.precipitation)
        }
         
        return PointMark(
            x: .value("date", graphData.date),
            y: .value("value", value)
        )
        .symbol(symbol: {
            Image(systemName: graphData.symbol)
            .foregroundStyle(.orange)
            .background {
                Circle()
                .blendMode(.destinationOut)
                .frame(width: 25, height: 25)
            }
        })
        .annotation(spacing: annotationSpacing(graphData: graphData)) {
            Text(annotation)
            .font(.caption)
        }
    }
    
    fileprivate func graphData() -> [GraphData] {
        if kind == .daily {
            return weatherModel.dailyGraphData
        } else if kind == .hourly {
            return weatherModel.houlyGraphData
        } else {
            return weatherModel.minutelyGraphData ?? []
        }
    }
    
    fileprivate func placeholderData(day: Int, series: GraphData.Series, value: Int) -> GraphData {
        let date = Date().addingTimeInterval(Self.day * Double(day))
        return GraphData(date: date, series: series.rawValue, temperature: .init(value: Double(value), unit: .celsius), symbol: "cloud.sun")
    }
    
    fileprivate func axisMarksStride() -> AxisMarkValues {
        if kind == .daily {
            return .stride(by: .day)
        } else if kind == .hourly {
            return .stride(by: .hour)
        } else {
            return .stride(by: .minute)
        }
    }
    
    fileprivate func frameWidth() -> CGFloat {
        if fullWidth {
            return geometryProxy.size.width
        }

        #if os(watchOS)
            if kind == .daily {
                return geometryProxy.size.width * 2
            } else if kind == .hourly {
                return geometryProxy.size.width * 4
            } else {
                return geometryProxy.size.width * 6
            }
        #elseif os(macOS)
            if kind == .daily {
                return geometryProxy.size.width * 0.9
            } else if kind == .hourly {
                return geometryProxy.size.width * 2
            } else {
                return geometryProxy.size.width * 7
            }
        #else
            if kind == .daily {
                return geometryProxy.size.width * 0.9
            } else {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return geometryProxy.size.width * 0.9 // ipad hourly and minutely
                } else {
                    if kind == .hourly {
                        return geometryProxy.size.width * 2.5 // iphone hourly
                    } else {
                        return geometryProxy.size.width * 8 // iphone minutely
                    }
                }
            }
        #endif
    }

    fileprivate func annotationSpacing(graphData: GraphData) -> CGFloat {
        #if os(watchOS)
            if graphData.series == GraphData.Series.temperatureHigh.rawValue {
                return 5
            } else {
                return -35
            }
        #else
            if graphData.series == GraphData.Series.temperatureHigh.rawValue {
                return 5
            } else {
                return -40
            }
        #endif
    }
}

#Preview {
    GeometryReader() { geometryProxy in
        WeatherGraphView(weatherModel: WeatherModel(city: City()), kind: .daily, geometryProxy: geometryProxy, placeholder: true, fullWidth: false)
        .frame(width: 300)
    }
    .frame(width: 300)
}
