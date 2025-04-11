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

extension GAFError: Equatable {
    static func == (lhs: GAFError, rhs: GAFError) -> Bool {
        switch (lhs, rhs) {
        case (.serverError(let lhsError), .serverError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.responseError(let lhsCode), .responseError(let rhsCode)):
            return lhsCode == rhsCode
        case (.noDataReceived, .noDataReceived):
            return true
        case (.badUrl, .badUrl):
            return true
        default:
            return false
        }
    }
}
