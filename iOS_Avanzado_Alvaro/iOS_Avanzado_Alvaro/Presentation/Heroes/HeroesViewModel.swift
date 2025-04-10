//
//  heroesState.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 8/4/25.
//


import Foundation



enum heroesState {
    case dataUpdated
    case errorLoadingHeroes(error: GAFError)
}

final class HeroesViewModel {
    private var heroes: [Hero] = []
    private var useCase: HeroesUseCaseProtocol
    private var securedData: SecureDataProtocol
    private var storedData: StoreSwiftDataProvider
    
    
    var stateChanged: ((heroesState) -> Void)?
    
    
    init(useCase: HeroesUseCaseProtocol = HeroesUseCase(),securedData: SecureDataProtocol = SecureDataProvider(), storedData: StoreSwiftDataProvider = .shared) {
        self.useCase = useCase
        self.securedData = securedData
        self.storedData = storedData
    }
    
    func loadData() {
        useCase.loadHeroes {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let heroes):
                    self?.heroes = heroes
                    self?.stateChanged?(.dataUpdated)
                case .failure(let error):
                    self?.stateChanged?(.errorLoadingHeroes(error: error))
                }
            }
        }
    }
    
    func fetchHeroes() -> [Hero] {
        return heroes
    }
    
    func performLogout() {
        securedData.clearToken()
        storedData.clearBBDD()
    }
    
    func heroWith(index: Int) -> Hero? {
        guard index < heroes.count else {
            return nil
        }
        return heroes[index]
    }
    
}
