//
//  RequestBuilder.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import Foundation


final class RequestBuilder {
    let host = "dragonball.keepcoding.education"
    
    private var secureData: SecureDataProtocol
    
    init(secureData: SecureDataProtocol = SecureDataProvider()) {
        self.secureData = secureData
    }
    
    // Recibe el endpoint y configura la url en funcion del caso.
    func url(endPoint: GAFEndpoint) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = endPoint.path()
        
        return components.url
    }
    
    func buildLoginRequest(endpoint: GAFEndpoint) throws(GAFError) -> URLRequest {
        guard let url = url(endPoint: endpoint) else {
            throw GAFError.badUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod()
        
        if let authHeader = endpoint.authorizationHeader {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        } else {
            throw GAFError.badUrl
        }
        return request
    }
    
    
    func buildAuthenticatedRequest(endpoint: GAFEndpoint) throws(GAFError) -> URLRequest {
        
        guard let url = url(endPoint: endpoint) else {
            throw .badUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod()
        
        // Para los endpoints que requieran autorizacion obtenemos el token de sesion
        guard let token = secureData.getToken() else {
            throw .sessionTokenMissed
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // Siempre hay que establecer el encabezado Content-Type al formato estandar para
        // las solicitudes API que envian y reciben JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        // Si el endpoint requiere parametros en el cuerpo de la solicitud(POST o PUT por ejemplo)
        // Lo hacemos mediante params()
        request.httpBody = endpoint.params()
        
        return request
    }
    
    func build(endpoint: GAFEndpoint) throws(GAFError) -> URLRequest {
        if endpoint.isLoginEndpoint {
            return try buildLoginRequest(endpoint: endpoint)
        }
        
        else if endpoint.isAuthoritationRequired {
            return try buildAuthenticatedRequest(endpoint: endpoint)
        }
        else {
            throw .badUrl
        }
    }

    
}
