//
//  Hero.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import Foundation
import SwiftData

@Model public class MOHero {
    #Unique<MOHero>([\.identifier])
    var favorite: Bool?
    var identifier: String?
    var info: String?
    var name: String?
    var photo: String?
    
    // Relación con MOHeroLocation
    @Relationship(deleteRule: .cascade, inverse: \MOHeroLocation.hero) var locations: [MOHeroLocation]?
    // Relacion con MOHeroTransformation
    @Relationship(deleteRule: .cascade, inverse: \MOHeroTransformation.hero) var transformations: [MOHeroTransformation]?
    
    init(favorite: Bool? = nil, identifier: String? = nil, info: String? = nil, name: String? = nil, photo: String? = nil) {
        self.favorite = favorite
        self.identifier = identifier
        self.info = info
        self.name = name
        self.photo = photo
    }
}

extension MOHero {
    func mapToHero() -> Hero {
        Hero(id: self.identifier ?? "",
             favorite: self.favorite,
             name: self.name,
             description: self.info,
             photo: self.photo)
    }
}


