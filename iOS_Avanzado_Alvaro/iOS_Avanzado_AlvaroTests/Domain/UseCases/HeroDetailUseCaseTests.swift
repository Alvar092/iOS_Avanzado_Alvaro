//
//  HeroDetailUseCase.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 11/4/25.
//

import XCTest
@testable import iOS_Avanzado_Alvaro

final class HeroDetailUseCaseTests: XCTestCase {
    
    var sut: HeroDetailUseCase!
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
        sut = HeroDetailUseCase(storedData: storedData, apiProvider: apiProvider)
    }
    
    override func tearDownWithError() throws {
        storedData.clearBBDD()
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = nil
        sut = nil
        secureData.clearToken()
        try super.tearDownWithError()
    }
    
    
    func testFetchLocationsForHero() throws {
        // GIVEN
        let expectation = XCTestExpectation(description: "Fetch locations from cache")
        let heroId = "hero123"
        
        // Crear un HeroLocation vacío (sin ubicación)
        let mockHeroLocation = ApiHeroLocation(id: "location1", longitude: nil, latitude: nil, date: nil, hero: ApiHero(id: "hero123", name: nil, description: nil, photo: nil))  // Ubicación vacía
        
        // Crear el héroe con el id hero123 y asignarle la ubicación vacía
        let mockHero = ApiHero(id: heroId, name: nil, description: nil, photo: nil)
        // Insertar el héroe en la base de datos (SwiftData)
        storedData.insert(heroes: [mockHero])  // Asegúrate de que tienes un método insertHero para insertar el héroe
        storedData.insert(locations: [mockHeroLocation])
        
        sut.fetchLocationsForHeroWith(id: heroId) { result in
            
            switch result {
            case .success(let locations):
                XCTAssertEqual(locations.count, 1)
                XCTAssertEqual(locations.first?.id, "location1")
            case .failure:
                XCTFail("Call should success")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
