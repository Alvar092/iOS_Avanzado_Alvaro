//
//  HeroesUseCaseTests.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 11/4/25.
//

import XCTest
@testable import iOS_Avanzado_Alvaro

// Para los tests del caso de uso hacemos uso de MockURProtocol y el singleton de StoreSwiftDataProvider
// que persiste la BBD en memoria
final class HeroesUseCaseTests: XCTestCase {
    
    var sut: HeroesUseCase!
    var storedData: StoreSwiftDataProvider!
    var secureData: SecureDataProtocol!
    let expectedToken = "token"

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        storedData = .sharedTesting
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        
        secureData = MockSecureDataProvider()
        let requestBuilder = RequestBuilder(secureData: secureData)
        let apiProvider = ApiProvider(session: session, requestBuilder: requestBuilder)
        sut = HeroesUseCase(apiProvider: apiProvider, storedData: storedData)
        secureData.setToken(expectedToken)
    }

    override func tearDownWithError() throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = nil
        storedData.clearBBDD()
        sut = nil
        secureData.clearToken()
        try super.tearDownWithError()
    }
    
    // Test de la función loadHeroes
    // SE hace test de todas las funciones que no son privadas.
    func testLoadHeroes_shouldReturnOrderingAcending() throws {
        
        // GIVEN
        var expectedHeroes: [Hero] = []
        MockURLProtocol.requestHandler = { request in
                let urlData = try XCTUnwrap(Bundle(for: ApiProviderTests.self).url(forResource: "Heroes", withExtension: "json"))
                let data = try Data(contentsOf: urlData)
            
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 200))
            
            return (response, data)
        }
        let initialCountHeroesInBDD = storedData.numHeroes()
        
        // WHEN
        let expectation = expectation(description: "Usecase return heroes")
        sut.loadHeroes { result in
            switch result {
            case .success(let heroes):
                expectedHeroes = heroes
                expectation.fulfill()
            case .failure(_):
                XCTFail("Waititng for ssuccess")
            }
        }
        
        // THEN
        wait(for: [expectation], timeout: 0.1)
        
        let finalCountHeroesInBBDD = storedData.numHeroes()
        
        XCTAssertEqual(initialCountHeroesInBDD, 0)
        XCTAssertEqual(finalCountHeroesInBBDD, 15)
        XCTAssertEqual(expectedHeroes.count, 15)
        
        let hero = try XCTUnwrap(expectedHeroes.first)
        
        XCTAssertEqual(hero.name, "Androide 17")
        XCTAssertEqual(hero.favorite, true)
        XCTAssertEqual(hero.id, "963CA612-716B-4D08-991E-8B1AFF625A81")
        let expectedDesc = "Es el hermano gemelo de Androide 18. Son muy parecidos físicamente, aunque Androide 17 es un joven moreno. También está programado para destruir a Goku porque fue el responsable de exterminar el Ejército Red Ribbon. Sin embargo, mató a su creador el Dr. Gero por haberle convertido en un androide en contra de su voluntad. Es un personaje con mucha confianza en sí mismo, sarcástico y rebelde que no se deja pisotear. Ese exceso de confianza le hace cometer errores que pueden costarle la vida"
        XCTAssertEqual(hero.description, expectedDesc)
        XCTAssertEqual(hero.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2019/10/dragon-ball-androide-17.jpg?width=300")
    }
    
    func testLoadHeroes_shouldReturnLocalHeroesWhenAvailable() throws {
        // GIVEN: Creamos un heroe y lo preinsertamos en la base
        let localHero = Hero(id: "1", favorite: false, name: "Goku", description: "Saiyan", photo: "url")
        storedData.insert(heroes: [ApiHero(id: "1", favorite: false, name: "Goku", description: "Saiyan", photo: "url")])

        var resultHeroes: [Hero] = []

        //WHEN: llamamos a loadHeroes
        let expectation = expectation(description: "Usecase returns local heroes")
        sut.loadHeroes { result in
            switch result {
            case .success(let heroes):
                resultHeroes = heroes
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success")
            }
        }

        // THEN: Debería retornar lo local sin provocar una solicitud a red
        wait(for: [expectation], timeout: 0.1)

        XCTAssertEqual(resultHeroes.count, 1)
        XCTAssertEqual(resultHeroes.first?.id, "1")
        XCTAssertEqual(resultHeroes.first?.name, "Goku")
    }
    
}
// GIVEN

// WHEN

// THEN


