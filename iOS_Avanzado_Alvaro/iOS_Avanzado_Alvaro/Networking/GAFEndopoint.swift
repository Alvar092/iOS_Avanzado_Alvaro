//
//  GAFEndopoint.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import Foundation

enum HTTPMethods: String {
    case POST, GET, PUT, DELETE
}

// Endpoints para servicios que nos da:
// - El path
// - El httpmethod
// - Params si son necesarios
enum GAFEndpoint {
    case heroes(name: String)
    case locations(id: String)
    case login(username: String, password: String)
    
    
    var authorizationHeader: String? {
        switch self {
        case .login(let username, let password):
            let login = "\(username):\(password)"
            guard let loginData = login.data(using: .utf8) else { return nil }
            return "Basic \(loginData.base64EncodedString())"
        default:
            return nil
        }
    }
    
    // Variable para indicar si el endpoint debe llevar cabecera de autenticación con el token
    var isAuthoritationRequired: Bool {
        switch self {
        case .heroes, .locations:
            return true
        case .login:
            return false
        }
    }
    
    var isLoginEndpoint: Bool {
        switch self {
        case .login:
            return true
        default:
            return false
        }
    }
    
    func path() -> String {
        switch self {
        case .login:
            return "/api/auth/login"
        case .heroes:
            return "/api/heros/all"
        case .locations:
            return "/api/heros/locations"
        }
    }
    
    func httpMethod() -> String {
        switch self {
        case .login, .heroes, .locations:
            return HTTPMethods.POST.rawValue
        }
    }
    
    func params() -> Data? {
        switch self {
        case .login:
            return nil
            
        case .heroes(name: let name):
            let attributes = ["name": name]
            // Creamos Data a partir de un dicionario
            let data = try? JSONSerialization.data(withJSONObject: attributes)
            return data
            
        case .locations(id: let id):
            let attributes = ["id": id]
            // Creamos Data a partir de un dicionario
            let data = try? JSONSerialization.data(withJSONObject: attributes)
            return data
        }
    }
}
