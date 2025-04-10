//
//  MOHeroTransformation.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 9/4/25.
//

import Foundation
import SwiftData

@Model public class MOHeroTransformation {
    var identifier: String
    var name: String?
    var info: String?
    var photo: String?
    var hero: MOHero?
    
    init(identifier: String, name: String? = nil, info: String? = nil, photo: String? = nil, hero: MOHero? = nil) {
        self.identifier = identifier
        self.name = name
        self.info = info
        self.photo = photo
        self.hero = hero
    }
}

extension MOHeroTransformation {
    func mapToHeroTransformation() -> HeroTransformation {
        HeroTransformation(id: self.identifier,
                           name: self.name ?? "",
                           description: self.info ?? "",
                           photo: self.photo ?? "")
    }
}
