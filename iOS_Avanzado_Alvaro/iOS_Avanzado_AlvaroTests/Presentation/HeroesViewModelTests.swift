//
//  Heroes.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 13/4/25.
//

import XCTest
@testable import iOS_Avanzado_Alvaro

class MockHeroesUseCase: HeroesUseCaseProtocol {
    func loadHeroes(completion: @escaping (Result<[Hero], GAFError>) -> Void) {
        do{
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTests.self).url(forResource: "Heroes", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            let response = try JSONDecoder().decode([ApiHero].self, from: data)
            completion(.success(response.map({$0.mapToHero()})))
        } catch {
            completion(.failure(.errorParsingData))
        }
    }
}

class MochHeroesUseCaseError: HeroesUseCaseProtocol {
    func loadHeroes(completion: @escaping (Result<[Hero], GAFError>) -> Void) {
        completion(.failure(.noDataReceived))
    }
}

final class HeroesViewModelTests: XCTestCase {
    
    var sut: HeroesViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoadData() throws {
        // GIVEN: Establezco una variable donde recibir los heroes e inicializo el sut
        var expectedHeroes: [Hero] = []
        sut = HeroesViewModel(useCase: MockHeroesUseCase(), storedData: .sharedTesting )
        
        // WHEN: Esperamos info de los cambios del viewModel usando expectation
        let expectation = expectation(description: "ViewModel load heroes and inform")
        sut.stateChanged = {[weak self] state in
            switch state {
            case .dataUpdated:
                expectedHeroes = self?.sut.fetchHeroes() ?? []
                expectation.fulfill()
            case .errorLoadingHeroes(error: _):
                XCTFail("Los heroes deberían haber cargado")
            }
        }
        sut.loadData()
        
        //THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(expectedHeroes.count, 15)
        
    }
}


extension ApiHero {
    func mapToHero() -> Hero {
        Hero(id: self.id,
             favorite: self.favorite,
             name: self.name,
             description: self.description,
             photo: self.photo)
    }

}


// GIVEN

// WHEN

//THEN
