//
//  SearchResult.swift
//  Forecast
//

import CoreLocation

struct SearchResult: Identifiable, Hashable {
    var id: String {
        get {
            return name
        }
    }
    var name: String
    var info: String
    var location: CLLocation?
    
    init() {
        name = ""
        info = ""
    }
    
    init(name: String, info: String) {
        self.name = name
        self.info = info
    }
}
