//
//  SplashViewModel.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import Foundation

// Representamos el estado del Splash
enum SplashState: Equatable {
    case loading
    
    case error
    
    case ready
}

final class SplashViewModel {
   
    let onStateChanged = Binding<SplashState>()
    
    func load() {
        onStateChanged.update(.loading)
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.onStateChanged.update( .ready)
        }
    }
}
