//
//  HeroDetailBuilder.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 9/4/25.
//

import UIKit

final class HeroDetailBuilder {
    
    private let hero: Hero
    
    init(hero: Hero) {
        self.hero = hero
    }
    
    static func build(hero: Hero) -> UIViewController {
        let locationsUseCase = HeroDetailUseCase()
        let transformationsUseCase = HeroTransformationUseCase()
        let viewModel = HeroDetailViewModel(hero: hero, locationsUseCase: locationsUseCase, transformationsUseCase: transformationsUseCase)
        let controller = HeroDetailController(viewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}
