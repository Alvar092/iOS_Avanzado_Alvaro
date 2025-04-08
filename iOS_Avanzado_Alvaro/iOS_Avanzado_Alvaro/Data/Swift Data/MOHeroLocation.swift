//
//  HeroLocation.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import Foundation
import SwiftData

@Model public class MOHeroLocation {
    var date: String?
    var identifier: String?
    var latitude: String?
    var longitude: String?
    var hero: MOHero?

    init(date: String? = nil, identifier: String? = nil, latitude: String? = nil, longitude: String? = nil, hero: MOHero? = nil) {
        self.date = date
        self.identifier = identifier
        self.latitude = latitude
        self.longitude = longitude
        self.hero = hero
    }
}

extension MOHeroLocation {
    func mapToHeroLocation() -> HeroLocation {
        HeroLocation(id: self.identifier ?? "",
                     longitude: self.longitude,
                     latitude: self.latitude,
                     date: self.date,
                     hero: self.hero?.mapToHero())
    }
}

