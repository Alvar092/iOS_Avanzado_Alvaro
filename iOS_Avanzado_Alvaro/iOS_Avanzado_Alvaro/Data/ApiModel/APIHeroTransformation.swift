//
//  APIHeroTransformation.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 9/4/25.
//



struct ApiHeroTransformation: Codable {
    let id: String
    let hero: ApiHero?
    let name: String
    let description: String?
    let photo: String?
}



