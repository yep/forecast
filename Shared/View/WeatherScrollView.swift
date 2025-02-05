//
//  WeatherScrollView.swift
//  Forecast
//

import SwiftUI

struct WeatherScrollView<Content: View>: View {
    var content: () -> Content

    var body: some View {
        #if os(watchOS)
            ScrollView(.horizontal, showsIndicators: false) {
                content()
            }
        #else
            content()
        #endif
    }
}
