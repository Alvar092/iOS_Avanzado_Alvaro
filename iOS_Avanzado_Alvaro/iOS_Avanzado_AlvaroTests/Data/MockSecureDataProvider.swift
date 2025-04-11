//
//  MockSecureDataProvider.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 11/4/25.
//

import Foundation
@testable import iOS_Avanzado_Alvaro

// Creamos un mock de SecureDataProtocol para hacer test unitarios sin tocar el llavero real.
// Hacemos uso de UserDefault para no modificar la info de la app.
struct MockSecureDataProvider: SecureDataProtocol {
    let keyToken = "keytoken"
    
    // Se usa la instancia estandar de UserDefaults, que guarda datos simples localmente en la app.
    let userDefaults = UserDefaults.standard
    
    func getToken() -> String? {
        userDefaults.value(forKey: keyToken) as? String
    }
    
    func setToken(_ token: String) {
        userDefaults.setValue(token, forKey: keyToken)
    }
    
    func clearToken() {
        userDefaults.removeObject(forKey: keyToken)
    }
}

