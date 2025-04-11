//
//  ApiProviderTests.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 11/4/25.
//

import XCTest
@testable import iOS_Avanzado_Alvaro

final class ApiProviderTests: XCTestCase {
    var sut: ApiProvider!
    var secureData: SecureDataProtocol!
    let expectedToken = "token"
    
    // setUp y tearDown se ejecutan con cada test.
    // setup antes de ejecutarse y tearDown al finalizar, idelaes para configurar y limpiar respectivamente el objeto
    // sobre el que hacemos el test
    override func setUpWithError() throws {
       // Creamos la URLSession usando nuestro Mock de URLProtocol en la configuración
        try super.setUpWithError()
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        // Creamos ApiProvider con usando nuestra session en el constructor
        // usamos nuestro Mock de secureData para crear el api provider y poder guardar y borrar el token sin afectar a la app
        secureData = MockSecureDataProvider()
        let requestBuilder = RequestBuilder(secureData: secureData)
        sut = ApiProvider(session: session, requestBuilder: requestBuilder)
        secureData.setToken(expectedToken)
    }

    // Importante restablecer el estado de sut y MockURLProtocol tras cada test
    override func tearDownWithError() throws {
        MockURLProtocol.requestHandler = nil
        MockURLProtocol.error = nil
        sut = nil
        secureData.clearToken()
        try super.tearDownWithError()
    }
    
    // Test que comprueba el correcto funcionamiento de la llamada a heroes de la api
    func testFetchHeroes() throws {
        // GIVEN
        var expectedHeroes: [ApiHero] = []
        
        // Inicializamos el MockURLProtocol
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            // Guardamos en una variable la request que nos devuelve el mock para validaciones posteriores.
            receivedRequest = request
            
            // Creamos la Data que recibiría la app en el dataTask
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTests.self).url(forResource: "Heroes", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            
            // Creamos la response que recibiría la app en el dataTask
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 200))
            
            return (response, data)
        }
        
        // WHEN
        // procesos asincronos hacemos uso de expectations que nos permite esperar a que se jecuten
        let expectation = expectation(description: "load heroes")
        sut.fetchHeroes { result in
            switch result {
            case .success(let heroes):
                // Con fullfil indicamos que expectation se ha compltado
                expectation.fulfill()
                expectedHeroes = heroes
            case .failure(let error):
                XCTFail("Waiting for success")
            }
        }
        
        // THEN
        wait(for: [expectation], timeout: 3.0)
        
        // Validamos la info del a request
        XCTAssertEqual(receivedRequest?.url?.absoluteString, "https://dragonball.keepcoding.education/api/heros/all")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertEqual(receivedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json; charset=utf-8")
        XCTAssertEqual(receivedRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer \(expectedToken)")
        
        // Validamos la información recibida de la función
        XCTAssertEqual(expectedHeroes.count, 15)
        let hero = try XCTUnwrap(expectedHeroes.first)
        
        XCTAssertEqual(hero.name, "Maestro Roshi")
        XCTAssertEqual(hero.id, "14BB8E98-6586-4EA7-B4D7-35D6A63F5AA3")
        XCTAssertEqual(hero.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2020/06/Roshi.jpg?width=300")
        XCTAssertFalse(hero.favorite!)
        let expectedDesc = "Es un maestro de artes marciales que tiene una escuela, donde entrenará a Goku y Krilin para los Torneos de Artes Marciales. Aún en los primeros episodios había un toque de tradición y disciplina, muy bien representada por el maestro. Pero Muten Roshi es un anciano extremadamente pervertido con las chicas jóvenes, una actitud que se utilizaba en escenas divertidas en los años 80. En su faceta de experto en artes marciales, fue quien le enseñó a Goku técnicas como el Kame Hame Ha"
        XCTAssertEqual(hero.description, expectedDesc)

    }
    
    // Test de la función de fetchHeroes cuando recibe un error del servidor
    // para ello usamos la varibale error de Mock URLPRotocol
    func testfetchHeroes_ServerError() {
        // GIVEN
        MockURLProtocol.error = NSError(domain: "io.keepcoding.B19", code: 503)
        var expectedError: GAFError?
        
        // WHEN
        let expectation = expectation(description: "load heroes fail")
        // Cuando en un tests se lanza un exception el sistema por defecto da por completada la expectations
        // poniendo a false esta variable podemos evitar ese comportamiento
        expectation.assertForOverFulfill = false
        
        sut.fetchHeroes { result in
            switch result {
            case .success(_):
                XCTFail("Waiting for failure")
            case .failure(let error):
                expectedError = error
                expectation.fulfill()
            }
        }
        
        // THEN
        wait(for: [expectation], timeout: 0.2)
        XCTAssertNotNil(expectedError)
    }
    
    // Test de la función de fetchHeroes cuando recibe un error de status Code
    // DEcidimos el startusCode al crear el response
    func testFechtHeroes_StatusCodeError() {
        // Given
        var expectedError: GAFError?
        
        // Para simular el estado 401
        MockURLProtocol.requestHandler = { request in
            // se carga el JSON simulado pero no se usa en este caso
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTests.self).url(forResource: "Heroes", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            
            // Se crea la respuesta HTTP con 401
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 401))
            
            // Retornamos la respuesta con el data simulado
            return (response, data)
        }
        
        // When
        let expectation = expectation(description:" Load heroes fails with status Code 401")
        // Ejecutamos el metodo para la solicitud
        sut.fetchHeroes { result in
            switch result {
            case .success(_):
                XCTFail("Waiting for failure")
            case .failure(let error):
                expectedError = error
                expectation.fulfill()
            }
        }
        
        // Then: Esperamos y validamos que haya recibido error. 
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(expectedError)
        
    }
    
    func testLogin() throws {
        // GIVEN: Simulamos una respuesta 200 que contiene un tokenJWT
        var expectedToken: String?
        
        MockURLProtocol.requestHandler = { request in
            let token = "FalseToken"
            let data = token.data(using: .utf8)!
            
            let urlRequest = try XCTUnwrap(request.url)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: urlRequest, statusCode: 200))
            
            return (response, data)
        }
        
        // WHEN: ejecutamos la solicitud, que debería devolver success
        let expectation = expectation(description: "Login success with token")
        sut.login(username: "testUser", password: "testPassword") { result in
            switch result {
            case .success(let token):
                expectedToken = token
                expectation.fulfill()
            case .failure:
                XCTFail("Error")
            }
        }
        
        // THEN
        wait(for: [expectation], timeout: 0.3)
        XCTAssertEqual(expectedToken, "FalseToken")
        
    }

    func testLogin_NetworkError() {
        // GIVEN: Simulamos el error de red
        var expectedError: GAFError?
        
        MockURLProtocol.requestHandler = { request in
            let error = NSError(domain: "com.network.error", code: -1009, userInfo: nil)
            throw error
        }
        // WHEN
        let expectation = expectation(description: "Login fails due to network error")
        sut.login(username: "testUser", password: "testPassword") { result in
            switch result {
            case .success:
                XCTFail("Waiting for error, not success")
            case .failure(let error):
                expectedError = error
                expectation.fulfill()
            }
        }

        // THEN
        wait(for: [expectation], timeout: 0.3)
        XCTAssertEqual(expectedError, GAFError.serverError(error: NSError(domain: "com.network.error", code: -1009, userInfo: nil)))
    }
    
    func testFetchLocationsForHero() throws {
        // GIVEN
        let expectedLocations = [
            ApiHeroLocation(
                id: "36E934EC-C786-4A8F-9C48-A6989BCA929E",
                longitude: "139.8202084625344",
                latitude: "35.71867899343361",
                date: "2024-10-20T00:00:00Z",
                hero: nil
            ),
            ApiHeroLocation(
                id: "20FA102F-2E47-42DF-899B-CC2848DD0EB3",
                longitude: "-77.036",
                latitude: "38.8202084625344",
                date: "2024-10-20T00:00:00Z",
                hero: nil
            )
        ]

        
        MockURLProtocol.requestHandler = { request in
            let urlData = try XCTUnwrap(Bundle(for: ApiProviderTests.self).url(forResource: "Locations", withExtension: "json"))
            let data = try Data(contentsOf: urlData)
            let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: request.url!, statusCode: 200))
            return (response, data)
        }
        // WHEN
        let expectation = expectation(description: "load hero locations")
            var resultLocations: [ApiHeroLocation] = []
            sut.fetchLocationsForHeroWith(id: "heroId") { result in
                switch result {
                case .success(let locations):
                    resultLocations = locations
                    expectation.fulfill()
                case .failure:
                    XCTFail("Expected success, but got failure")
                }
            }
        // THEN
        wait(for: [expectation], timeout: 1.0)
            XCTAssertEqual(resultLocations.count, expectedLocations.count)
            XCTAssertEqual(resultLocations.first?.id, expectedLocations.first?.id)
            XCTAssertEqual(resultLocations.first?.longitude, expectedLocations.first?.longitude)
            XCTAssertEqual(resultLocations.first?.latitude, expectedLocations.first?.latitude)
    }
    
    func testFetchTransformationsForHero() throws {
        // GIVEN
        let expectedTransformations = [
            ApiHeroTransformation(id: "17824501-1106-4815-BC7A-BFDCCEE43CC9",
                                  hero: nil,
                                  name: "1. Oozaru – Gran Mono",
                                  description: "Cómo todos los Saiyans con cola, Goku es capaz de convertirse en un mono gigante si mira fijamente a la luna llena. Así es como Goku cuando era un infante liberaba todo su potencial a cambio de perder todo el raciocinio y transformarse en una auténtica bestia. Es por ello que sus amigos optan por cortarle la cola para que no ocurran desgracias, ya que Goku mató a su propio abuelo adoptivo Son Gohan estando en este estado. Después de beber el Agua Ultra Divina, Goku liberó todo su potencial sin necesidad de volver a convertirse en Oozaru",
                                  photo: "https://areajugones.sport.es/wp-content/uploads/2021/05/ozarru.jpg.webp")]
            MockURLProtocol.requestHandler = { request in
                let urlData = try XCTUnwrap(Bundle(for: ApiProviderTests.self).url(forResource: "Transformation", withExtension: "json"))
                let data = try Data(contentsOf: urlData)
                let response = try XCTUnwrap(MockURLProtocol.httpResponse(url: request.url!, statusCode: 200))
                return (response, data)
            }
        // WHEN
        let expectation = expectation(description: "load hero transformations")
            var resultTransformations: [ApiHeroTransformation] = []
            sut.fetchTransformationsForHero(id: "heroId") { result in
                switch result {
                case .success(let transformations):
                    resultTransformations = transformations
                    expectation.fulfill()
                case .failure:
                    XCTFail("Expected success, but got failure")
                }
            }
        // THEN
        wait(for: [expectation], timeout: 1.0)
            XCTAssertEqual(resultTransformations.count, expectedTransformations.count)
            XCTAssertEqual(resultTransformations.first?.id, expectedTransformations.first?.id)
            XCTAssertEqual(resultTransformations.first?.name, expectedTransformations.first?.name)
        }
    }


// GIVEN

// WHEN

// THEN
