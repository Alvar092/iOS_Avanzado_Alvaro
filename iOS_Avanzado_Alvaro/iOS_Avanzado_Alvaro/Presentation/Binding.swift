//
//  Bind.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//
import Foundation

// Clase que permite la vinculación entre viewModel y la vista,
// notificando los cambios en el estado de la aplicación.

// 'Binding' asegura que las actualizaciones se realicen en el hilo principal cuando sea necesario.
final class Binding<T: Equatable> {
    
    // Closure generico aplicable a varios casos de uso
    typealias Completion = (T) -> Void
    
    private var completion: Completion?
    
    
    func bind(completion: @escaping Completion) {
        self.completion = completion
    }
    
    func update(_ state: T) {
        if Thread.current.isMainThread {
            completion?(state)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.completion?(state)
            }
        }
    }
}
