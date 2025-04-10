//
//  HeroTransformationUseCasa.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 10/4/25.
//

import Foundation

protocol HeroTransformationUseCaseProtocol {
    func fetchTransformationsForHero(id: String, completion: @escaping(Result<[HeroTransformation], GAFError>)-> Void)
}

class HeroTransformationUseCase: HeroTransformationUseCaseProtocol {
   
    private var storedData: StoreSwiftDataProvider
    private var apiProvider: ApiProvider
    
    init(storedData: StoreSwiftDataProvider = .shared, apiProvider: ApiProvider = .init()) {
        self.storedData = storedData
        self.apiProvider = apiProvider
    }
    
    func
    fetchTransformationsForHero(id: String, completion: @escaping(Result<[HeroTransformation], GAFError>)-> Void) {
        let transformations = storedTransformationsForHeroWith(id: id)
        
        if transformations.isEmpty {
            apiProvider.fetchTransformationsForHero(id: id) { result in
                switch result {
                case .success(let transformations):
                    self.storedData.insert(transformations: transformations)
                    let moTransformation = self.storedTransformationsForHeroWith(id:id)
                    completion(.success(moTransformation))
                
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(transformations))
        }
    }
    
    func storedTransformationsForHeroWith(id: String) -> [HeroTransformation] {
        let predicate = #Predicate<MOHero> { hero in hero.identifier == id}
        guard let hero = storedData.fetchHeroes(filter: predicate).first,
              let transformations = hero.transformations else {
            return []
        }
        let mapped = transformations.map({$0.mapToHeroTransformation()})
        return mapped
    }
}
