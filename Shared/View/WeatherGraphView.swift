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
import WidgetKit

struct WeatherGraphView: View {
    enum Kind {
        case daily
        case hourly
        case minutely
    }
    enum WeatherWidgetFamily {
        case none
        case rectangular
        case small
        case medium
        case large
    }
    var weatherModel: WeatherModel
    private let geometryProxy: GeometryProxy
    private let kind: Kind
    private var fullWidth: Bool
    private var widgetFamily = WeatherWidgetFamily.none

    init(weatherModel: WeatherModel, kind: Kind, geometryProxy: GeometryProxy, placeholder: Bool = false, fullWidth: Bool = false, widgetFamily: WidgetFamily? = nil) {
        self.weatherModel  = weatherModel
        self.geometryProxy = geometryProxy
        self.kind          = kind
        self.fullWidth     = fullWidth
        
        #if os(iOS) || os(watchOS)
        if widgetFamily == .accessoryRectangular {
            self.widgetFamily = .rectangular
        }
        #endif
        
        #if os(iOS) || os(macOS)
        if widgetFamily == .systemSmall {
            self.widgetFamily = .small
        } else if widgetFamily == .systemMedium {
            self.widgetFamily = .medium
        } else if widgetFamily == .systemLarge {
            self.widgetFamily = .large
        }
        #endif
        
        if placeholder {
            weatherModel.houlyGraphData = GraphData.placeholderData()
            weatherModel.dailyGraphData = GraphData.placeholderData()
        }
    }
    var body: some View {
        Chart() {
            ForEach(graphData(), id: \.id) { graphData in
                lineMark(graphData: graphData, low: true)
                lineMark(graphData: graphData, low: false)
                pointMarkNumber(graphData: graphData, low: true)
                pointMarkNumber(graphData: graphData, low: false)
                pointMarkSymbol(graphData: graphData)
            }
        }
        .frame(width: frameWidth())
        .chartYScale(domain: graphDataMin() ... graphDataMax())
        .chartYAxis(widgetFamily == .rectangular ? .hidden : .visible)
        .chartXAxis(widgetFamily == .rectangular ? .hidden : .visible)
        .chartXAxis(content: {
            AxisMarks(preset: .aligned, values: axisMarksStride()) { axisValue in
                if let date = axisValue.as(Date.self) {
                    AxisValueLabel() {
                        Text(axisLabelString(date: date))
                    }
                }
            }
        })
    }
    
    // MARK: - Private
    
    fileprivate func lineMark(graphData: GraphData, low: Bool) -> some ChartContent {
        var value: Double
        var series: String
        if kind == .minutely {
            value = graphData.precipitation.value
            series = "precipitation"
        } else if low {
            value = graphData.temperatureLow.value
            series = "temperatureLow"
        } else {
            value =  graphData.temperatureHigh.value
            series = "temperatureHigh"
        }
        
        return LineMark(
            x: .value("", graphData.date),
            y: .value("", value),
            series: .value("", series)
        )
        .foregroundStyle(Color.orange.opacity(0.5))
        .interpolationMethod(.catmullRom)
    }
    
    fileprivate func pointMarkNumber(graphData: GraphData, low: Bool) -> some ChartContent {
        var value: Double
        var annotation: String
        var position: AnnotationPosition = .top
        
        if kind == .minutely {
            value = graphData.precipitation.value
            annotation = StringFormatter.precipitationString(graphData.precipitation)
        } else if low {
            value = graphData.temperatureLow.value
            annotation = StringFormatter.temperatureString(graphData.temperatureLow)
            position = .bottom
        } else {
            value = graphData.temperatureHigh.value
            annotation = StringFormatter.temperatureString(graphData.temperatureHigh)
        }
        
        return PointMark(
            x: .value("date", graphData.date),
            y: .value("value", value)
        )
        .foregroundStyle(.clear)
        .annotation(position: position) {
            Text(annotation)
                .font(.system(size: 11))
        }
    }
    
    fileprivate func pointMarkSymbol(graphData: GraphData) -> some ChartContent {
        var value: Double
        let size: CGFloat = 20
        var offset: CGFloat = 15
        
        if kind == .minutely {
            value = graphData.precipitation.value
        } else if kind == .hourly {
            value = graphData.temperatureHigh.value
        } else {
            value = (graphData.temperatureLow.value + graphData.temperatureHigh.value) / 2
            offset = 0
        }
         
        return PointMark(
            x: .value("date", graphData.date),
            y: .value("value", value)
        )
        .symbol(symbol: {
            Image(systemName: StringFormatter.fill(icon: graphData.symbol))
                .foregroundStyle(.orange)
                .frame(width: size, height: size)
                .offset(y: offset)
        })
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
    
    fileprivate func graphDataMin() -> Double {
        var result = 999.9
        let graphData = self.graphData()
        for i in 0 ..< graphData.count {
            for value in [graphData[i].temperatureLow.value, graphData[i].temperatureHigh.value, graphData[i].precipitation.value] {
                if value < result {
                    result = value
                }
            }
        }
        return result - 6
    }
    
    fileprivate func graphDataMax() -> Double {
        var result = -999.9
        let graphData = self.graphData()
        for i in 0 ..< graphData.count {
            for value in [graphData[i].temperatureLow.value, graphData[i].temperatureHigh.value, graphData[i].precipitation.value] {
                if value > result {
                    result = value
                }
            }
        }
        return result + 6
    }
    
    fileprivate func axisLabelString(date: Date) -> String {
        if kind == .daily {
            return StringFormatter.weekdayString(date: date)
        } else if kind == .hourly {
            return "\(Calendar.current.component(.hour, from: date))"
        } else {
            return StringFormatter.timeString(date: date)
        }
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
                return geometryProxy.size.width * 1.5
            } else if kind == .hourly {
                return geometryProxy.size.width * 4
            } else {
                return geometryProxy.size.width * 10
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
            // iOS
            if kind == .daily {
                return geometryProxy.size.width * 0.9
            } else {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return geometryProxy.size.width * 0.9 // ipad hourly and minutely
                } else {
                    if kind == .hourly {
                        return geometryProxy.size.width * 1.8 // iphone hourly
                    } else {
                        return geometryProxy.size.width * 8 // iphone minutely
                    }
                }
            }
        #endif
    }
}

#Preview {
    GeometryReader() { geometryProxy in
        WeatherGraphView(weatherModel: WeatherModel(city: City()), kind: .daily, geometryProxy: geometryProxy, placeholder: true, fullWidth: false)
        .padding()
    }
}
