//
//  HeroDetailUseCase.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 9/4/25.
//

import Foundation

protocol HeroDetailUseCaseProtocol {
    func fetchLocationsForHeroWith(id: String, completion: @escaping(Result <[HeroLocation], GAFError>) -> Void)
}

class HeroDetailUseCase: HeroDetailUseCaseProtocol {
    
    private var storedData: StoreSwiftDataProvider
    private var apiProvider: ApiProvider
    
    init(storedData: StoreSwiftDataProvider = .shared, apiProvider: ApiProvider = .init()) {
        self.storedData = storedData
        self.apiProvider = apiProvider
    }
    
    func fetchLocationsForHeroWith(id: String, completion: @escaping (Result<[HeroLocation], GAFError>) -> Void) {
        let locations = storedLocationsForHeroWith(id: id)
        
        if locations.isEmpty {
            apiProvider.fetchLocationsForHeroWith(id: id) { [weak self] result in
                switch result {
                case .success(let locations):
                    self?.storedData.insert(locations: locations)
                    let moLocations = self?.storedLocationsForHeroWith(id: id) ?? []
                    completion(.success(moLocations))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(locations))
        }
    }
    
    func storedLocationsForHeroWith(id: String) -> [HeroLocation] {
        let predicate = #Predicate<MOHero> { hero in
            hero.identifier == id
        }
        guard let hero = storedData.fetchHeroes(filter: predicate).first,
              let locations = hero.locations else {
            return []
        }
        return locations.map({$0.mapToHeroLocation()})
    }
}
