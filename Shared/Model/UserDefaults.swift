//
//  UserDefaults.swift
//  Forecast
//

import Foundation
import CoreLocation

extension UserDefaults {
    static let indexMaxKey  = "indexMax"
    static let nameKey      = "name"
    static let infoKey      = "info"
    static let latitudeKey  = "latitude"
    static let longitudeKey = "longitude"
    static let selectionKey = "selection"

    func add(city: City) {
        let indexMax = UserDefaults.standard.integer(forKey: Self.indexMaxKey)
        var indexFound: Int?
        
        for i in 0 ..< indexMax {
            if let cityName = UserDefaults.standard.string(forKey: "\(Self.nameKey)\(i)"),
               cityName == city.name
            {
                indexFound = i
                break
            }
        }
        
        let index = indexFound ?? indexMax
        UserDefaults.standard.set(city.name, forKey: "\(Self.nameKey)\(index)")
        UserDefaults.standard.set(city.info, forKey: "\(Self.infoKey)\(index)")
        UserDefaults.standard.set(city.location?.coordinate.latitude,  forKey: "\(Self.latitudeKey)\(index)")
        UserDefaults.standard.set(city.location?.coordinate.longitude, forKey: "\(Self.longitudeKey)\(index)")
        UserDefaults.standard.set(indexMax + 1, forKey: Self.indexMaxKey)
        UserDefaults.standard.synchronize()
    }
    
    func delete(cityIndex indexToDelete: Int) {
        let indexMax = UserDefaults.standard.integer(forKey: Self.indexMaxKey)
        var count = 0
        
        for index in 0 ..< indexMax {
            if UserDefaults.standard.object(forKey: "\(Self.nameKey)\(index)") != nil {
                if index < indexMax && count == indexToDelete {
                    UserDefaults.standard.removeObject(forKey: "\(Self.nameKey)\(index)")
                    UserDefaults.standard.removeObject(forKey: "\(Self.infoKey)\(index)")
                    UserDefaults.standard.removeObject(forKey: "\(Self.latitudeKey)\(index)")
                    UserDefaults.standard.removeObject(forKey: "\(Self.longitudeKey)\(index)")
                    UserDefaults.standard.synchronize()
                }
                count += 1
            }
        }
    }
    
    func getCities() -> [City] {
        let indexMax = UserDefaults.standard.integer(forKey: Self.indexMaxKey)
        var result: [City] = []
        
        for index in 0 ..< indexMax {
            if UserDefaults.standard.object(forKey: "\(Self.nameKey)\(index)") != nil {
                result.append(createCity(index: index))
            }
        }
        
        return result
    }
    
    func set(selectedCity: City) {
        let indexMax = UserDefaults.standard.integer(forKey: Self.indexMaxKey)
        
        for index in 0 ..< indexMax {
            if let cityName = UserDefaults.standard.string(forKey: "\(Self.nameKey)\(index)"),
               cityName == selectedCity.name
            {
                UserDefaults.standard.set(index, forKey: "\(Self.selectionKey)")
                UserDefaults.standard.synchronize()
                break
            }
        }
    }
    
    func selectedCity() -> City? {
        let selectedIndex = UserDefaults.standard.integer(forKey: Self.selectionKey)
        let indexMax = UserDefaults.standard.integer(forKey: Self.indexMaxKey)

        if selectedIndex < indexMax {
            for index in 0 ..< indexMax {
                if selectedIndex == index,
                   UserDefaults.standard.object(forKey: "\(Self.nameKey)\(index)") != nil
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
        if let name = UserDefaults.standard.value(forKey: "\(Self.nameKey)\(index)") as? String {
            city.name = name
        }
        if let info = UserDefaults.standard.value(forKey: "\(Self.infoKey)\(index)") as? String {
            city.info = info
        }
        if let latitude  = UserDefaults.standard.value(forKey: "\(Self.latitudeKey)\(index)")  as? CLLocationDegrees,
           let longitude = UserDefaults.standard.value(forKey: "\(Self.longitudeKey)\(index)") as? CLLocationDegrees,
           latitude != 0, longitude != 0
        {
            city.location = CLLocation(latitude: latitude, longitude: longitude)
        }
        
        return city
    }
}
