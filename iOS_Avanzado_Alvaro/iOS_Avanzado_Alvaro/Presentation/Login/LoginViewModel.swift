//
//  LoginState.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//
import UIKit

enum LoginState: Equatable {
    case success
    case loading
    case error(reason: String)
}

class LoginViewModel {
    let useCase: LoginUseCaseProtocol
    
    let onStateChanged = Binding<LoginState>()
    
    init(useCase: LoginUseCaseProtocol) {
        self.useCase = useCase
    }
    
    func login(userName: String?, password: String?) {
        guard let userName, isValidUsername(userName) else {
            return onStateChanged.update(.error(reason: "Invalid username. Must be an email"))
        }
        guard let password, isValidPassword(password) else {
            return onStateChanged.update(.error(reason: "Invalid password. Must be at least 4 characters"))
        }
        onStateChanged.update(.loading)
        useCase.run(username: userName, password: password) {[weak self] result in
            switch result {
            case .success:
                self?.onStateChanged.update(.success)
            case .failure(let error):
                self?.onStateChanged.update(.error(reason: error.reason))
            }
        }
    }
    
    private func isValidUsername(_ username: String) -> Bool {
        username.contains("@") && !username.isEmpty
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        password.count >= 4
    }
}
