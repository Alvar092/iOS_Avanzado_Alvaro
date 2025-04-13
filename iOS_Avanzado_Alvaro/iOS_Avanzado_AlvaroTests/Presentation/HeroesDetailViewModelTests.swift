//
//  HeroesDetailViewModelTests.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 13/4/25.
//

import XCTest

@testable import iOS_Avanzado_Alvaro

final class MockHeroDetailUseCase: HeroDetailUseCaseProtocol {
    func fetchLocationsForHeroWith(id: String, completion: @escaping (Result<[iOS_Avanzado_Alvaro.HeroLocation], iOS_Avanzado_Alvaro.GAFError>) -> Void) {
        do {
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTests.self).url(forResource: "Locations", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            let response = try JSONDecoder().decode([ApiHeroLocation].self, from: data)
            completion(.success(response.map({$0.mapToHeroLocation()})))
        } catch {
            completion(.failure(.errorParsingData))
        }
    }
}

final class MockHeroDetailUseCaseError: HeroDetailUseCaseProtocol {
    func fetchLocationsForHeroWith(id: String, completion: @escaping (Result<[iOS_Avanzado_Alvaro.HeroLocation], iOS_Avanzado_Alvaro.GAFError>) -> Void) {
        completion(.failure(.errorParsingData))
    }
    
    
}

final class MockHeroTransformationUseCase: HeroTransformationUseCaseProtocol {
    func fetchTransformationsForHero(id: String, completion: @escaping (Result<[iOS_Avanzado_Alvaro.HeroTransformation], iOS_Avanzado_Alvaro.GAFError>) -> Void) {
        do {
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTests.self).url(forResource: "Transformation", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            let response = try JSONDecoder().decode([ApiHeroTransformation].self, from: data)
            completion(.success(response.map({$0.mapToHeroTransformation()})))
        } catch {
            completion(.failure(.errorParsingData))
        }
    }
}

final class MockHeroTransformationUseCaseError: HeroTransformationUseCaseProtocol {
    func fetchTransformationsForHero(id: String, completion: @escaping (Result<[iOS_Avanzado_Alvaro.HeroTransformation], iOS_Avanzado_Alvaro.GAFError>) -> Void) {
        completion(.failure(.errorParsingData))
    }
}

final class HeroDetailViewModelTests: XCTestCase {
    
    var sut: HeroDetailViewModel!
    var mockLocationsUseCase: MockHeroDetailUseCase!
    var mockTransformationsUseCase: MockHeroTransformationUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockLocationsUseCase = MockHeroDetailUseCase()
        mockTransformationsUseCase = MockHeroTransformationUseCase()
        sut = HeroDetailViewModel(
            hero: Hero(id: "123", name: nil, description: nil, photo: nil),
            locationsUseCase: mockLocationsUseCase,
            transformationsUseCase: mockTransformationsUseCase)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockLocationsUseCase = nil
        mockTransformationsUseCase = nil
        try super.tearDownWithError()
    }
    
    func testLoadData() {
        // GIVEN: Creamos un array donde recibir la localizaciones
        var expectedAnnotation: [HeroAnnotation] = []
        
        // WHEN: SImulamos la respuesta del viewModel para sacar las localizaciones
        let expectation = expectation(description: "ViewModel load locations and inform")
        sut.stateChanged = { state in
            switch state {
            case .locationsUpdated:
                expectedAnnotation = self.sut.getHeroLocations()
                expectation.fulfill()
            case.errorLoadingLocation(error: .noDataReceived):
                XCTFail("ViewModel should load locations")
            default:
                break
            }
        }
        sut.loadData()
        
        //THEN: Comprobamos que son las dos del JSON que tenemos preparado
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(expectedAnnotation.count, 2)
    }
    
    
    func testLoadTransformations() {
        // GIVEN
        var expectedTransformation: [HeroTransformation] = []
        
        // WHEN
        let expectation = expectation(description: "ViewModel load transformation and inform")
        sut.stateChanged = { state in
            switch state {
            case .transformationsUpdated:
                expectedTransformation = self.sut.transformations
                expectation.fulfill()
            case .errorLoadingTransformations:
                XCTFail("Expected successful loading of transformations")
            default:
                break
            }
        }
        sut.loadTransformations()
        //THEN:
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(expectedTransformation.count, 1)
        XCTAssertEqual(expectedTransformation.first?.name, "1. Oozaru – Gran Mono")
    }
}




extension ApiHeroLocation {
    func mapToHeroLocation() -> HeroLocation {
        HeroLocation(id: self.id,
                     longitude: self.longitude,
                     latitude: self.latitude,
                     date: self.date,
                     hero: self.hero?.mapToHero())
    }
}

extension ApiHeroTransformation{
    func mapToHeroTransformation() -> HeroTransformation {
        HeroTransformation(id: self.id,
                           name: self.name,
                           description: self.description ?? "",
                           photo: self.photo ?? "")
    }
}
// GIVEN

// WHEN

//THEN
