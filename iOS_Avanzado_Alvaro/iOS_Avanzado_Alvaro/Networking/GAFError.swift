//
//  GAFError.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import Foundation


// Enum para usar errorres personalizados en la api
enum GAFError: Error {
    case badUrl
    case serverError(error: Error)
    case responseError(code: Int?)
    case noDataReceived
    case errorParsingData
    case sessionTokenMissed
}
