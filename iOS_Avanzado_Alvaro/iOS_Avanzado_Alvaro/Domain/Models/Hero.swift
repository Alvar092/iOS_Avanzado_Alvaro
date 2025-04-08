//
//  Hero.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 8/4/25.
//

import Foundation

struct Hero: Hashable {
    let id: String
    var favorite: Bool?
    let name: String?
    let description: String?
    let photo: String?
}
