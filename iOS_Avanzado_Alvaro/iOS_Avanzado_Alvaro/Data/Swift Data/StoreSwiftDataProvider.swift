//
//  StoreSwiftDataProvider.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import Foundation
import SwiftData

// Enum para indicar los tipos de persistencia de nuestro BBDD de Core Data
enum TypePersistence {
    case disk
    case inMemory
}

// Configuramos modelo, contexto y cosas básicas.
final class StoreSwiftDataProvider {
    
    static let shared: StoreSwiftDataProvider = .init()
    
#if DEBUG
    static let sharedTesting: StoreSwiftDataProvider = .init(persistence: .inMemory)
#endif
    
    let modelContainer: ModelContainer
    lazy var context: ModelContext = {
        let ctx = ModelContext(modelContainer)
        return ctx
    }()
    
    private let urlStore = URL.applicationSupportDirectory.appending(component: "Model.sqlite")
    
    init(persistence: TypePersistence = .disk) {
        var configuration = ModelConfiguration(url: urlStore)
        if persistence == .inMemory {
            configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        }
        do {
            self.modelContainer = try ModelContainer(for: MOHero.self, configurations: configuration)
        } catch {
            fatalError("Swift data couldn't load BBDD from model \(error)")
        }
    }
    
    func saveContext(){
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
        } catch {
            debugPrint("There was an error saving the context \(error)")
        }
    }
}

// Agrupamos la gestión de datos concretos.
extension StoreSwiftDataProvider {
    
    // Obtiene array de heroes de la BBDD. Se puede aplicar un filtro/predicado.
    func fetchHeroes(filter: Predicate <MOHero>?, sortAscending: Bool = true) -> [MOHero] {
        
        // Ordena por nombre, ascendente o descendente
        let sortDescriptor = SortDescriptor<MOHero>(\.name, order: sortAscending ? .forward : .reverse)
        // Equivalente a NSFetchRequest
        let request = FetchDescriptor(predicate: filter, sortBy:[sortDescriptor])
        
        return (try? context.fetch(request)) ?? []
    }
    
    func numHeroes() -> Int {
        return (try? context.fetchCount(FetchDescriptor<MOHero>())) ?? 0
    }
    
    func insert(heroes: [ApiHero]) {
        for hero in heroes {
            let newHero = MOHero(favorite: hero.favorite,
                                 identifier: hero.id,
                                 info: hero.description,
                                 name: hero.name,
                                 photo: hero.photo)
            context.insert(newHero)
        }
        saveContext()
    }
    
    func insert(locations: [ApiHeroLocation]) {
        for location in locations {
            let filter = #Predicate<MOHero>{ hero in
                hero.identifier == location.hero?.id
            }
            let hero = fetchHeroes(filter: filter).first
            
            let newLocation = MOHeroLocation(date: location.date,
                                             identifier: location.id,
                                             latitude: location.latitude,
                                             longitude: location.longitude,
                                             hero: hero)
            context.insert(newLocation)
        }
        saveContext()
    }
    
    func clearBBDD() {
        // Quitamos los cambios pendientes que haya en el contexto
        context.rollback()
        
        do {
            // Borra directamente de la BBDD similar el BSBatchDeleteRequest
            try context.delete(model: MOHero.self)
            try context.delete(model: MOHeroLocation.self)
        } catch {
            debugPrint("There wwas an error clearing BBDD \(error)")
        }
    }
}
