//
//  UserDefaults.swift
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

import Foundation
import CoreLocation

@MainActor extension UserDefaults {
    static let indexMaxKey  = "indexMax"
    static let nameKey      = "name"
    static let infoKey      = "info"
    static let latitudeKey  = "latitude"
    static let longitudeKey = "longitude"
    static let selectionKey = "selection"
    
    static let appGroup = UserDefaults(suiteName: "group.com.github.yep.ios.weatherapp") ?? UserDefaults.standard

    func add(city: City) {
        let indexMax = Self.appGroup.integer(forKey: Self.indexMaxKey)
        var indexFound: Int?
        
        for i in 0 ..< indexMax {
            if let cityName = Self.appGroup.string(forKey: "\(Self.nameKey)\(i)"),
               cityName == city.name
            {
                indexFound = i
                break
            }
        }
        
        let index = indexFound ?? indexMax
        Self.appGroup.set(city.name, forKey: "\(Self.nameKey)\(index)")
        Self.appGroup.set(city.info, forKey: "\(Self.infoKey)\(index)")
        Self.appGroup.set(city.location?.coordinate.latitude,  forKey: "\(Self.latitudeKey)\(index)")
        Self.appGroup.set(city.location?.coordinate.longitude, forKey: "\(Self.longitudeKey)\(index)")
        Self.appGroup.set(indexMax + 1, forKey: Self.indexMaxKey)
        synchronize()
    }
    
    func delete(cityIndex indexToDelete: Int) {
        let indexMax = Self.appGroup.integer(forKey: Self.indexMaxKey)
        var count = 0
        
        for index in 0 ..< indexMax {
            if Self.appGroup.object(forKey: "\(Self.nameKey)\(index)") != nil {
                if index < indexMax && count == indexToDelete {
                    Self.appGroup.removeObject(forKey: "\(Self.nameKey)\(index)")
                    Self.appGroup.removeObject(forKey: "\(Self.infoKey)\(index)")
                    Self.appGroup.removeObject(forKey: "\(Self.latitudeKey)\(index)")
                    Self.appGroup.removeObject(forKey: "\(Self.longitudeKey)\(index)")
                    synchronize()
                }
                count += 1
            }
        }
    }
    
    func getCities() -> [City] {
        let indexMax = Self.appGroup.integer(forKey: Self.indexMaxKey)
        var result: [City] = []
        
        for index in 0 ..< indexMax {
            if Self.appGroup.object(forKey: "\(Self.nameKey)\(index)") != nil {
                result.append(createCity(index: index))
            }
        }
        
        return result
    }
    
    func set(selectedCity: City) {
        let indexMax = Self.appGroup.integer(forKey: Self.indexMaxKey)
        
        for index in 0 ..< indexMax {
            if let cityName = Self.appGroup.string(forKey: "\(Self.nameKey)\(index)"),
               cityName == selectedCity.name
            {
                Self.appGroup.set(index, forKey: "\(Self.selectionKey)")
                synchronize()
                break
            }
        }
    }
    
    func selectedCity() -> City? {
        let selectedIndex = Self.appGroup.integer(forKey: Self.selectionKey)
        let indexMax = Self.appGroup.integer(forKey: Self.indexMaxKey)

        if selectedIndex < indexMax {
            for index in 0 ..< indexMax {
                if selectedIndex == index,
                   Self.appGroup.object(forKey: "\(Self.nameKey)\(index)") != nil
                {
                    return createCity(index: index)
                }
            }
        }
        return nil
    }
    
    // MARK: - Private
    
    fileprivate func createCity(index: Int) -> City {
        var city = City()
        if let name = Self.appGroup.value(forKey: "\(Self.nameKey)\(index)") as? String {
            city.name = name
        }
        if let info = Self.appGroup.value(forKey: "\(Self.infoKey)\(index)") as? String {
            city.info = info
        }
        if let latitude  = Self.appGroup.value(forKey: "\(Self.latitudeKey)\(index)")  as? CLLocationDegrees,
           let longitude = Self.appGroup.value(forKey: "\(Self.longitudeKey)\(index)") as? CLLocationDegrees,
           latitude != 0, longitude != 0
        {
            city.location = CLLocation(latitude: latitude, longitude: longitude)
        }
        
        return city
    }
}
