//
//  ForecastApp.swift
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
