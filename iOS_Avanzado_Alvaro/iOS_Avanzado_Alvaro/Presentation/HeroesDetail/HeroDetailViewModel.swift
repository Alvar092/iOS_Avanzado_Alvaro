//
//  HeroDetailViewModel.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 9/4/25.
//

import UIKit
import Foundation

enum HeroDetailState {
    case locationsUpdated
    case errorLoadingLocation(error: GAFError)
}


class HeroDetailViewModel {
    
    private (set) var hero : Hero
    private var useCase: HeroDetailUseCaseProtocol
    private var locations: [HeroLocation] = []
    var stateChanged: ((HeroDetailState) -> Void)?
    
    init(hero: Hero, useCase: HeroDetailUseCaseProtocol = HeroDetailUseCase()) {
        self.hero = hero
        self.useCase = useCase
    }
    
    func loadData() {
        useCase.fetchLocationsForHeroWith(id: hero.id) { [weak self]  result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    self?.locations = locations
                    self?.stateChanged?(.locationsUpdated)
                case .failure(let error):
                    self?.stateChanged?(.errorLoadingLocation(error: error))
                }
            }
        }
    }
    
    func getHeroLocations() -> [HeroAnnotation] {
        var annotations: [HeroAnnotation] = []
        for location in locations {
            if let coordinate = location.coordinate {
                annotations.append(HeroAnnotation(coordinate: coordinate, title: hero.name))
            }
        }
        return annotations
    }
}
