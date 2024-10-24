//
//  ForecastApp.swift
//  Forecast
//

import SwiftUI

@main
struct ForecastApp: App {
#if os(macOS)
    fileprivate static let size = CGFloat(500)
#endif
    
    var body: some Scene {
#if os(macOS)
        WindowGroup {
            LocationView()
                .frame(maxWidth: Self.size, maxHeight: Self.size)
        }
        .defaultSize(width: Self.size, height: Self.size)
        .windowResizability(.contentSize)
#else
        WindowGroup {
            LocationView()
        }
#endif
    }
}
