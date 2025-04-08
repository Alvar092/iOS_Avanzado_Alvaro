//
//  HeroesUseCase.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 8/4/25.
//

protocol HeroesUseCaseProtocol {
    func loadHeroes(completion: @escaping (Result<[Hero], GAFError>)-> Void)
}

final class HeroesUseCase: HeroesUseCaseProtocol {
    
    private let apiProvider: ApiProvider
    private let storedData: StoreSwiftDataProvider
    
    init(apiProvider: ApiProvider = ApiProvider(), storedData: StoreSwiftDataProvider = .shared) {
        self.apiProvider = apiProvider
        self.storedData = storedData
    }
    
    func loadHeroes(completion: @escaping (Result<[Hero], GAFError>)-> Void) {
        let localHeroes = loadHeroes()
        
        // Comprobamos si tenemos los datos en BBD sis es así los usamos, si no se piden al servicio web
        if loadHeroes().isEmpty {
            apiProvider.fetchHeroes { [weak self] result in
                switch result {
                case .success(let apiHeroes):
                    self?.storedData.insert(heroes: apiHeroes)
                    completion(.success(self?.loadHeroes() ?? []))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(localHeroes))
        }
    }
        
    
    private func loadHeroes() -> [Hero] {
        
    // Uso de un predicado para filtrar los items en una tabla de la BBDD
    // let filter = NSPredicate(format: "name CONTAINS[cd] %@", "an")
    // let heroes = storedData.fetchHeroes(filter: filter)
        let heroes = storedData.fetchHeroes(filter: nil)
        return heroes.map({$0.mapToHero()})
    }
        
    
}
