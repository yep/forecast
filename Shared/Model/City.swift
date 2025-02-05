//
//  City.swift
//  Forecast
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
