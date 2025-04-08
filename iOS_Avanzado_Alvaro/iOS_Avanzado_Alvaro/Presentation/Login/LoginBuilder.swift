//
//  LoginBuilder.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//
import UIKit

// Este Construye y configura el modulo de Login
// Ensambla las dependencias necesarias y devuelve un UIViewController listo para su presentacion
class LoginBuilder {
   static func build() -> UIViewController {
        let useCase = LoginUseCase()
        let viewModel = LoginViewModel(useCase: useCase)
        let controller = LoginViewController(viewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}
