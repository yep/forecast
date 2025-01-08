//
//  WeatherOverlayView.swift
//  Forecast
//

import SwiftUI
import WeatherKit

struct WeatherOverlayView: View {
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        if let legalPageURL = viewModel.legalPageURL {
            VStack(alignment: .trailing) {
                Spacer()
                VStack {
                    Link(destination: legalPageURL) {
                        AsyncImage(url: viewModel.attributionLogoURL, scale: 4.0)
                    }
                    .foregroundStyle(.clear)
                    .frame(width: 50)
                    #if os(watchOS)
                    .padding(.bottom, -20)
                    #else
                    .padding(0)
                    #endif

                    Link(destination: legalPageURL) {
                        Text("Other data sources")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.foreground)
                    .font(.system(size: 12, weight: .light))
                    .padding(0)
                }
                #if os(watchOS)
                .padding(.bottom, -30)
                #else
                .padding(.bottom, 40)
                #endif
            }
        }
    }
}

#Preview {
    WeatherOverlayView()
}
