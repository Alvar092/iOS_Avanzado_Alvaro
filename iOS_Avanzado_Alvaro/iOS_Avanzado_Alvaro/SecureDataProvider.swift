//
//  SecureDataProvider.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import Foundation
import KeychainSwift

protocol SecureDataProtocol {
    func getToken() -> String?
    func setToken(_ token: String)
    func clearToken()
}




// Hace uso de Keychain para guardar la información del token en el llavero del dispositivo
struct SecureDataProvider: SecureDataProtocol {
    
    //Referencia al valor del token en sesion
    private let keyToken = "keyToken"
    
    private let keychain = KeychainSwift()
    
    
    func getToken() -> String? {
        keychain.get(keyToken)
    }
    
    func setToken(_ token: String) {
        keychain.set(token, forKey: keyToken)
    }
    
    func clearToken() {
        keychain.delete(keyToken)
    }
    
     
    func clearBBDD() {
        
    }
    
    
    
}


