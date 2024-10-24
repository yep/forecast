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
                HStack {
                    Link(destination: legalPageURL) {
                        AsyncImage(url: viewModel.attributionLogoURL, scale: 4.0)
                    }
                    .foregroundStyle(.clear)
                    .frame(width: 50)

                    Link(destination: legalPageURL) {
                        Text("Attribution")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.foreground)
                    .padding(.top, 2)
                    .font(.system(size: 12, weight: .light))
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
