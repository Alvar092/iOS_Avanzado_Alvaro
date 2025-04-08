//
//  SplashBuilder.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

final class SplashBuilder {
    func build() -> SplashController {
        let viewModel = SplashViewModel()
        return SplashController(viewModel: viewModel)
    }
}
