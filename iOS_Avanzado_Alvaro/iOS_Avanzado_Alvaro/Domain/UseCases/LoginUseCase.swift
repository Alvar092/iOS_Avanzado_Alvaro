//
//  LoginUseCase.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import Foundation

struct LoginError: Error {
    let reason: String
}

// Para invertir la inyeccion de dependencias, con el protocolo dependemos
// de un comportamiento y no de un objeto (aunque se comporta igual, pero esto es como coger la llave y no al sereno).
protocol LoginUseCaseProtocol {
    // Ejecuta la autenticación con las credenciales
    func run(username: String, password: String, completion: @escaping (Result<Void, LoginError>) -> Void)
}

// Caso de uso para gestionar la autenticación del usuario
final class LoginUseCase: LoginUseCaseProtocol {
    
    private let apiProvider: ApiProvider
    private let secureData: SecureDataProtocol
    
    
    // inicializa el caso con un punto de origen de datos para iniciar la sesión.
    // Entiendo que aqui se guardaran los datos de primeras y se guardarían en persistencia mientras estamos en el ajo.
    init(apiProvider: ApiProvider = .init(),secureData: SecureDataProvider = .init()) {
        self.apiProvider = apiProvider
        self.secureData = secureData
    }
    
    // Para un user y pass retorna un parametro
    func run(username: String, password: String, completion: @escaping (Result<Void, LoginError>) -> Void) {
        guard isValidUsername(username) else {
            return completion(.failure(LoginError(reason: "El usuario no es válido")))
        }
        guard isValidPassword(password) else {
                return completion(.failure(LoginError(reason: "La contraseña no es válida")))
        }
        
        apiProvider.login(username: username, password: password) { [weak self] result in
            switch result {
            case .success(let token):
                self?.secureData.setToken(token)
                completion(.success(()))
                print("EXITO!")
            case .failure:
                completion(.failure(LoginError(reason: "Ha ocurrido un error en la red")))
            }
        }
        
    }
    
    private func isValidUsername(_ string: String) -> Bool {
        !string.isEmpty && string.contains("@")
    }
    
    private func isValidPassword(_ string: String) -> Bool {
        string.count >= 4
    }
}
