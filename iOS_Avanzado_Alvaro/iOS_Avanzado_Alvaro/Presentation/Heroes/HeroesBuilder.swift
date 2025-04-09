//
//  HeroesBuilder.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 9/4/25.
//
import UIKit

final class HeroesBuilder {
    static func build() -> UIViewController {
        let useCase = HeroesUseCase()
        let viewModel = HeroesViewModel(useCase: useCase)
        let controller = HeroesController(viewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}
