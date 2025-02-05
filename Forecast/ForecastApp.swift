//
//  ForecastApp.swift
//  Forecast
//

import SwiftUI

@main
struct ForecastApp: App {
    #if os(macOS)
    fileprivate static let sizeMin = CGSize(width: 430, height: 600)
    fileprivate static let sizeMax = CGSize(width: 800, height: 1200)
    #endif
    
    var body: some Scene {
        #if os(macOS)
            WindowGroup {
                LocationView()
                    .frame(minWidth: Self.sizeMin.width, maxWidth: Self.sizeMax.width, minHeight: Self.sizeMin.height, maxHeight: Self.sizeMax.height)
            }
            .defaultSize(width: Self.sizeMin.width, height: Self.sizeMin.height)
            .windowResizability(.contentSize)
        #else
            WindowGroup {
                LocationView()
            }
        #endif
    }
}
