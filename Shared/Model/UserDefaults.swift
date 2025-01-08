//
//  UserDefaults.swift
//  Forecast
//

import Foundation
import CoreLocation

extension UserDefaults {
    static let indexKey = "index"
    static let nameKey = "name"
    static let latitudeKey = "latitude"
    static let longitudeKey = "longitude"
    
    func add(city: City) {
        let indexMax = UserDefaults.standard.integer(forKey: Self.indexKey)
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
        UserDefaults.standard.set(city.location?.coordinate.latitude,  forKey: "\(Self.latitudeKey)\(index)")
        UserDefaults.standard.set(city.location?.coordinate.longitude, forKey: "\(Self.longitudeKey)\(index)")
        UserDefaults.standard.set(indexMax + 1, forKey: Self.indexKey)
        UserDefaults.standard.synchronize()
    }
    
    func deleteCity(at index: Int) {
        let indexMax = UserDefaults.standard.integer(forKey: Self.indexKey)
        var count = 0
        for i in 0 ..< indexMax {
            if UserDefaults.standard.object(forKey: "\(Self.nameKey)\(i)") != nil {
                if i < indexMax && count == index {
                    UserDefaults.standard.removeObject(forKey: "\(Self.nameKey)\(i)")
                    UserDefaults.standard.removeObject(forKey: "\(Self.latitudeKey)\(i)")
                    UserDefaults.standard.removeObject(forKey: "\(Self.longitudeKey)\(i)")
                    UserDefaults.standard.synchronize()
                }
                count += 1
            }
        }
    }
    
    func getCities() -> [City] {
        let index = UserDefaults.standard.integer(forKey: Self.indexKey)
        var result: [City] = []
        
        for i in 0 ..< index {
            if let name = UserDefaults.standard.value(forKey: "\(Self.nameKey)\(i)") as? String {
                var city = City()
                city.name = name
                if let latitude  = UserDefaults.standard.value(forKey: "\(Self.latitudeKey)\(index)")  as? CLLocationDegrees,
                   let longitude = UserDefaults.standard.value(forKey: "\(Self.longitudeKey)\(index)") as? CLLocationDegrees,
                   latitude != 0, longitude != 0
                {
                    city.location = CLLocation(latitude: latitude, longitude: longitude)
                }
                result.append(city)
            }
        }
        
        return result
    }
}
