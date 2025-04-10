//
//  HeroDetailViewModel.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 9/4/25.
//

import UIKit
import Foundation

enum HeroDetailState {
    case transformationsUpdated
    case locationsUpdated
    case errorLoadingLocation(error: GAFError)
    case errorLoadingTransformations(error: GAFError)
}


class HeroDetailViewModel {
    
    private(set) var hero : Hero
    
    private var locationsUseCase: HeroDetailUseCaseProtocol
    private var locations: [HeroLocation] = []
    
    private(set) var transformations: [HeroTransformation] = []
    private var transformationsUseCase: HeroTransformationUseCaseProtocol
    
    var stateChanged: ((HeroDetailState) -> Void)?
    
    init(hero: Hero, locationsUseCase: HeroDetailUseCaseProtocol = HeroDetailUseCase(), transformationsUseCase: HeroTransformationUseCaseProtocol = HeroTransformationUseCase()) {
        self.hero = hero
        self.locationsUseCase = locationsUseCase
        self.transformationsUseCase = transformationsUseCase
    }
    
    func loadData() {
        locationsUseCase.fetchLocationsForHeroWith(id: hero.id) { [weak self]  result in
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
    
    // Convierto HeroLocation a HeroAnnotation para mostrar en mapa
    func getHeroLocations() -> [HeroAnnotation] {
        var annotations: [HeroAnnotation] = []
        for location in locations {
            if let coordinate = location.coordinate {
                annotations.append(HeroAnnotation(coordinate: coordinate, title: hero.name))
            }
        }
        return annotations
    }
    
    
    func loadTransformations() {
        transformationsUseCase.fetchTransformationsForHero(id: hero.id) {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let transformations):
                    // Ordeno de menor a mayor
                    let orderedTransformations = transformations.sorted{ lhs, rhs in
                        let lhsNumber = Int(lhs.name.components(separatedBy: CharacterSet.decimalDigits.inverted).first ?? "") ?? 0
                        let rhsNumber = Int(rhs.name.components(separatedBy: CharacterSet.decimalDigits.inverted).first ?? "") ?? 0
                        return lhsNumber < rhsNumber
                    }
                    self?.transformations = orderedTransformations
                    self?.stateChanged?(.transformationsUpdated)
                    
                    
                case .failure(let error):
                    self?.stateChanged?(.errorLoadingTransformations(error: error))
                }
            }
        }
    }
    
    func transformationWith(index: Int) -> HeroTransformation? {
        guard index < transformations.count else {
            return nil
        }
        return transformations[index]
    }
}
