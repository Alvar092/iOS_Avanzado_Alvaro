//
//  APIHeroLocation.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import Foundation

struct ApiHeroLocation: Codable {
    let id: String
    let longitude: String?
    let latitude: String?
    let date: String?
    let hero: ApiHero?
    
    enum CodingKeys: String, CodingKey  {
        case id
        case longitude = "longitud"
        case latitude = "latitud"
        case date = "dateShow"
        case hero
    }
    
}
