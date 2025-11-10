//
//  City.swift
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

import CoreLocation

struct City: Identifiable, Hashable {
    var id: String {
        get {
            return "\(name) \(info)"
        }
    }
    var name: String
    var info: String
    var longName: String {
        var text = self.name
        if self.info != "" {
            text = text.appending(", \(self.info)")
        }
        return text
    }
    var location: CLLocation?
    
    init(name: String = "", info: String = "") {
        self.name = name
        self.info = info
    }
}
