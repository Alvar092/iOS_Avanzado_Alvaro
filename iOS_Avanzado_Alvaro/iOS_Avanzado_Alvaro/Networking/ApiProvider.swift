//
//  ApiProvider.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import Foundation

struct ApiProvider {
    
    var session: URLSession
    var requestBuilder: RequestBuilder
    
    init(session: URLSession = .shared, requestBuilder: RequestBuilder = .init()) {
        self.session = session
        self.requestBuilder = requestBuilder
    }
    
//    func login(username: String, password: String, completion: @escaping (Result<String, GAFError>)-> Void) {
//        let endpoint = GAFEndpoint.login(username: username, password: password)
//        do{
//            let request = try requestBuilder.build(endpoint: endpoint)
//            manageResponse(urlRequest: request, completion: completion)
//        } catch {
//            completion(.failure(error))
//        }
//    }
    
    func login(username: String, password: String, completion: @escaping (Result<String, GAFError>) -> Void) {
        // Usamos el GAFEndpoint para crear la URLRequest
        let endpoint = GAFEndpoint.login(username: username, password: password)
        
        do {
            // Construir la solicitud usando el RequestBuilder
            let urlRequest = try requestBuilder.build(endpoint: endpoint)
            
            // Ejecutamos la tarea de red
            session.dataTask(with: urlRequest) { data, response, error in
                // Verificamos si hay error de red
                if let error = error {
                    completion(.failure(.serverError(error: error)))
                    return
                }
                
                // Verificamos el código de estado HTTP
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.responseError(code: nil)))
                    return
                }
                
                let statusCode = httpResponse.statusCode
                guard statusCode == 200 else {
                    completion(.failure(.responseError(code: statusCode)))
                    return
                }
                
                // Verificamos si hay datos
                guard let data = data else {
                    completion(.failure(.noDataReceived))
                    return
                }
                
                // Intentamos decodificar los datos
                do {
                    // Si la respuesta es un token JWT en formato String
                    if let token = String(data: data, encoding: .utf8) {
                        completion(.success(token))
                    }
                }
            }.resume()
        } catch {
            completion(.failure(.badUrl))
        }
    }

    

    
    func fetchHeroes(name: String = "", completion: @escaping (Result<[ApiHero], GAFError>) -> Void) {
        do{
            let request = try requestBuilder.build(endpoint: .heroes(name: name))
            manageResponse(urlRequest: request, completion: completion)
        } catch {
            completion(.failure(.errorParsingData))
        }
    }
    
    func fetchLocationsForHeroWith(id: String, completion: @escaping (Result<[ApiHeroLocation], GAFError>)-> Void) {
        do {
            let request = try requestBuilder.build(endpoint: .locations(id: id))
            manageResponse(urlRequest: request, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchTransformationsForHero(id: String, completion: @escaping (Result<[ApiHeroTransformation], GAFError>) -> Void) {
        do{
            let request = try requestBuilder.build(endpoint: .transformations(id: id))
            manageResponse(urlRequest: request, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    
    // Verifica si hay errores de red, el codigo de estado HTTP y decodifica el JSON
    // Usa generico para reutilizar la llamada en ambos servicios(heroes y locations)
    func manageResponse<T: Codable>(urlRequest: URLRequest, completion: @escaping (Result<T, GAFError>)-> Void) {
        //Verificamos si hay error de red
        session.dataTask(with: urlRequest) { data, response, error in
            // Verifico si hay error de red
            if let error {
                completion(.failure(.serverError(error: error)))
            }
            
            //Verifico el codigo de estado HTTP
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            
            guard statusCode == 200 else {
                completion(.failure(.responseError(code: statusCode)))
                return
            }
            
            // Verifico si hay datos
            guard let data else {
                completion(.failure(.noDataReceived))
                return
            }
                // Decodifico datos
                do {
                    // FALLA AQUI
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(.noDataReceived))
                }
        }.resume()
    }
}
