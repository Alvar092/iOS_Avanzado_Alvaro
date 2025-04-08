//
//  APIHero.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import Foundation

struct ApiHero: Codable {
    let id: String
    var favorite: Bool?
    let name: String?
    let description: String?
    let photo: String?
}
