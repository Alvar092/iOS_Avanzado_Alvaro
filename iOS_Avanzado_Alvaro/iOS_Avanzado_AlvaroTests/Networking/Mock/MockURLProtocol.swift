//
//  MockURLProtocol.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 11/4/25.
//

import Foundation

// Mock de URLProtocol, nos va a permitir capturar las llamadas a los servicios web y testar todo nuestro código
// de la api, loúnico que no hacemos es la llmamada al backend que es lo que no queremos.

class MockURLProtocol: URLProtocol {
    
    // PAra un caso de success recibiremos la request que podremos validar y haremos la función del backend
    // devolviendo el response y data que recive nuestro dataTask de ApiProvider.
    // Vamos, esto es un closure opcional que actua como backend simulado.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    // Daremos valor a error cuando queramos validar un caso de error.
    // Simula el fallo de red
    static var error: Error?
    
    // Que sea true siempre indica que manejara todas las peticiones
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    //Devuelve la misma peticion sin modificaciones
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    //Se llama cuando URLSession inicia una peticion de red.
    // Aqui es donde simulamos el comportamiento de la red.
    override func startLoading() {
        if let error = Self.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        // Me aseguro de que requesthandler esta definido.
        guard let handler =  Self.requestHandler else {
            fatalError("An error or request handler must be provided")
        }
        
        // Ejecutamos para obtener la respuesta simulando el flujo de red o el error.
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocolDidFinishLoading(self)
            
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    //Si la peticion se cancela o termina...
    override func stopLoading() {}
    
    // Función estática que nos permite crear un httpResponse de forma fácil.
    static func httpResponse(url: URL, statusCode: Int = 200) -> HTTPURLResponse? {
        HTTPURLResponse(url: url,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: ["Content-Type": "application/json; charset=utf-8"])
    }
    
}

