//
//  HeroTransformationUseCaseTests.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 11/4/25.
//

import XCTest
@testable import iOS_Avanzado_Alvaro

final class HeroTransformationUseCaseTests: XCTestCase {
    var sut: HeroTransformationUseCase!
    var storedData: StoreSwiftDataProvider!
    var secureData: SecureDataProtocol!
    let expectedToken = "token"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        storedData = .shared
        // Configurar el URLSession con MockURLProtocol
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        
        // Inicializar el mock para SecureData
        secureData = MockSecureDataProvider()
        
        // Crear el RequestBuilder y ApiProvider con la sesión modificada
        let requestBuilder = RequestBuilder(secureData: secureData)
        let apiProvider = ApiProvider(session: session, requestBuilder: requestBuilder)
        
        // Inicializar el sistema bajo prueba
        sut = HeroTransformationUseCase(storedData: storedData, apiProvider: apiProvider)
    }
    
    override func tearDownWithError() throws {
        storedData.clearBBDD()
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = nil
        sut = nil
        secureData.clearToken()
        try super.tearDownWithError()
    }
    
    func testFetchTransformations() throws {
        // GIVEN
        let expectation = XCTestExpectation(description: "Fetch transformations from cache")
        let heroId = "hero123"
        
        // Crear transformaciones mockeadas y almacenarlas en la caché
        let mockHero = ApiHero(id: heroId, name: "transformation1", description: nil, photo: nil)
        let mockTransformation = ApiHeroTransformation(id: heroId,
                                                       hero: mockHero,
                                                       name: "Super Saiyan",
                                                       description: "description",
                                                       photo: "photo")
        storedData.insert(heroes: [mockHero])
        storedData.insert(transformations: [mockTransformation])  // Inserta en la caché
        
        // WHEN: Llamamos a la función para obtener las transformaciones
        sut.fetchTransformationsForHero(id: heroId) { result in
            switch result {
            case .success(let transformations):
                // THEN: Verificamos que las transformaciones obtenidas son las de la caché
                XCTAssertEqual(transformations.count, 1)
                XCTAssertEqual(transformations.first?.id, "hero123")
                XCTAssertEqual(transformations.first?.name, "Super Saiyan")
            case .failure:
                XCTFail("Call should succeed")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
