//
//  UserDefaults.swift
//  Forecast
//

import Foundation
import CoreLocation

extension UserDefaults {
    static let nameKey = "name"
    static let latitudeKey = "latitude"
    static let longitudeKey = "longitude"
    
    func set(searchResult: SearchResult) {
        UserDefaults.standard.set(searchResult.name, forKey: Self.nameKey)
        UserDefaults.standard.set(searchResult.location?.coordinate.latitude, forKey: Self.latitudeKey)
        UserDefaults.standard.set(searchResult.location?.coordinate.longitude, forKey: Self.longitudeKey)
    }
    
    func getSearchResult() -> [SearchResult] {
        var result = SearchResult()
        result.name = UserDefaults.standard.value(forKey: Self.nameKey) as? String ?? ""
        
        if let latitude  = UserDefaults.standard.value(forKey: Self.latitudeKey) as? CLLocationDegrees,
           let longitude = UserDefaults.standard.value(forKey: Self.longitudeKey) as? CLLocationDegrees,
           latitude != 0, longitude != 0
        {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            result.location = location
            return [result]
        } else {
            return []
        }        
    }
}
