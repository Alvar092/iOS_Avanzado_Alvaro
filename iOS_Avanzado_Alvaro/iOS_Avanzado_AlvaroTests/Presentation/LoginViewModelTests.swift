//
//  LoginViewModelTests.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 13/4/25.
//

import XCTest
@testable import iOS_Avanzado_Alvaro

final class MockLoginUseCase: LoginUseCaseProtocol {
    func run(username: String = "correo@valido.com", password: String = "passValida", completion: @escaping (Result<Void, iOS_Avanzado_Alvaro.LoginError>) -> Void) {
        completion(.success(()))
    }
}

final class MockLoginUseCaseError: LoginUseCaseProtocol {
    func run(username: String = "correo@valido.com", password: String = "passValida", completion: @escaping (Result<Void, iOS_Avanzado_Alvaro.LoginError>) -> Void) {
        completion(.failure(LoginError(reason: "Error simulado")))
    }
}
    
    
final class LoginViewModelTests: XCTestCase {
        
    var sut: LoginViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLogin() throws {
        // GIVEN
        sut = LoginViewModel(useCase: MockLoginUseCase())
        var states: [LoginState] = []
        // WHEN: Creamos la expectation simulando la info del viewModel respecto a cambios de estado
        let expectation = expectation(description: "ViewModel login and inform")
        sut.onStateChanged.bind { state in
            states.append(state)
            if state == .success {
                expectation.fulfill()
            }
        }
        sut.login(userName: "correo@valido.com", password: "passValida")
        
        //THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(states, [.loading, .success])
    }
}
