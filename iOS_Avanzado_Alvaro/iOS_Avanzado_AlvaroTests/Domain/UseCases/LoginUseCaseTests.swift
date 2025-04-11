//
//  LoginUseCaseTests.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 11/4/25.
//
import XCTest
@testable import iOS_Avanzado_Alvaro

final class LoginUseCaseTests: XCTestCase {
    
    var sut: LoginUseCase!
    var secureData: SecureDataProtocol!
    let expectedToken = "token"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
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
        sut = LoginUseCase(apiProvider: apiProvider, secureData: secureData)
    }
    
    override func tearDownWithError() throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = nil
        sut = nil
        secureData.clearToken()
        try super.tearDownWithError()
    }
    
    func testLoginWithInvalidUsername() {
        // Given
        let expectation = XCTestExpectation(description: "Complete login with user not valid")
        let invalidUsername = "usuarioSinArroba"
        let password = "1234"
        var receivedError: LoginError?
        
        // When
        sut.run(username: invalidUsername, password: password) { result in
            switch result {
            case .success:
                XCTFail("Login should fail with user not valid")
            case .failure(let error):
                receivedError = error
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError?.reason, "User not valid")
    }
    
    func testLoginWithInvalidPassword() {
        // Given
        let expectation = XCTestExpectation(description: "Complete with a valid password")
        let username = "usuario@ejemplo.com"
        let invalidPassword = "123" // Menos de 4 caracteres
        var receivedError: LoginError?
        
        // When
        sut.run(username: username, password: invalidPassword) { result in
            switch result {
            case .success:
                XCTFail("Login should fail")
            case .failure(let error):
                receivedError = error
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError?.reason, "Invalid password")
    }
    
    func testLoginSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Login successful")
        let username = "usuario@ejemplo.com"
        let password = "1234"
        
        // Limpiar UserDefaults antes del test
        UserDefaults.standard.removeObject(forKey: "keytoken")
        
        // Configurar el MockURLProtocol para simular una respuesta exitosa
        MockURLProtocol.requestHandler = { request in
            // Simular respuesta del servidor con un token
            let tokenResponse = "token"
            let data = tokenResponse.data(using: .utf8)!
            let response = MockURLProtocol.httpResponse(url: request.url!, statusCode: 200)!
            
            return (response, data)
        }
        
        // Crear el mock de SecureData
        let mockSecureData = MockSecureDataProvider()
        
        // Crear el ApiProvider con el MockURLProtocol configurado
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        
        // Crear el LoginUseCase con el MockSecureData
        let apiProvider = ApiProvider(session: session, requestBuilder: RequestBuilder(secureData: mockSecureData))
        let sut = LoginUseCase(apiProvider: apiProvider, secureData: mockSecureData)
        
        // When
        sut.run(username: username, password: password) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Login should success")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockSecureData.getToken(), self.expectedToken)
    }
    
    func testLoginNetworkError() {
        // Given
        let expectation = XCTestExpectation(description: "Network error")
        let username = "usuario@ejemplo.com"
        let password = "1234"
        var receivedError: LoginError?
        
        // Configurar el MockURLProtocol para simular un error de red
        MockURLProtocol.error = NSError(domain: "test.error", code: -1009, userInfo: nil) // Error de conexión
        
        // When
        sut.run(username: username, password: password) { result in
            switch result {
            case .success:
                XCTFail("Login should fail")
            case .failure(let error):
                receivedError = error
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError?.reason, "Network error")
//        XCTAssertNil(.token)
    }
    
    func testLoginServerError() {
        // Given
        let expectation = XCTestExpectation(description: "Server error")
        let username = "usuario@ejemplo.com"
        let password = "1234"
        var receivedError: LoginError?
        
        // Configurar el MockURLProtocol para simular una respuesta de error del servidor
        MockURLProtocol.requestHandler = { request in
            // Simular respuesta de error 401 Unauthorized
            let jsonResponse = """
            {
                "error": "Not valid credential"
            }
            """
            let data = jsonResponse.data(using: .utf8)!
            let response = MockURLProtocol.httpResponse(url: request.url!, statusCode: 401)!
            
            return (response, data)
        }
        
        // When
        sut.run(username: username, password: password) { result in
            switch result {
            case .success:
                XCTFail("Login should fail due to a network error")
            case .failure(let error):
                receivedError = error
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError?.reason, "Ha ocurrido un error en la red")
//        XCTAssertNil(.token)
    }
}

