//
//  StoreSwiftDataProviderTests.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 11/4/25.
//

import XCTest
@testable import iOS_Avanzado_Alvaro

final class StoreDataProviderTests: XCTestCase {
    
    // Subject Under Test
    private var sut: StoreSwiftDataProvider!
    
    // Antes de cada test
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = .sharedTesting
    }
    
    // Despues de cada test limpiamos los datos insertados.
    override func tearDownWithError() throws {
        sut.clearBBDD()
        sut = nil
        try super.tearDownWithError()
    }
    
    func testInsertHeroes() throws {
        // GIVEN: Creamos un heroe simulado y comprobamos el número inicial de elementos
        let expectedHero = createHero()
        let initialCount = sut.fetchHeroes(filter: nil).count
        
        // WHEN: Insertamos el heroe en la base de datos
        sut.insert(heroes: [expectedHero])
        
        // THEN: Comprobamos que se ha incrementado el número de héroes
        let finalCount = sut.fetchHeroes(filter: nil).count
        XCTAssertEqual(initialCount, 0)
        XCTAssertEqual(finalCount, 1)
        
        // Validamos que los datos insertados coinciden con los esperados
        let hero = try XCTUnwrap(sut.fetchHeroes(filter: nil).first)
        XCTAssertEqual(hero.name, expectedHero.name)
        XCTAssertEqual(hero.info, expectedHero.description)
        XCTAssertEqual(hero.photo, expectedHero.photo)
        XCTAssertTrue(hero.favorite == true)
        XCTAssertNotNil(hero.identifier)
    }
    
    // Verifica que los héroes se devuelven ordenados alfabéticamente de forma ascendente
    func testFetchHeroes_shouldReturnHeroesOrderedAscending() throws {
        // GIVEN: Insertamos dos heroes
        let hero1 = createHero(with: "Oscar")
        let hero2 = createHero(with: "Jose Luis")
        sut.insert(heroes: [hero1, hero2])
        
        // WHEN: Obtenemos los heroes ordenados ascendentemente
        let heroes = sut.fetchHeroes(filter: nil, sortAscending: true)
        
        // THEN: El primer heroe debe ser "Jose Luis" por orden alfabético
        let firstHero = try XCTUnwrap(heroes.first)
        XCTAssertEqual(firstHero.name, hero2.name)
    }
    
    
    // Verifica que los heroes se filtran correctamente segun un predicado
    func testFetchHeroesShouldFilterItems() throws {
        // GIVEN: Insertamos dos heroes.
        let hero1 = createHero(with: "Pepe")
        let hero2 = createHero(with: "Jose Luis")
        sut.insert(heroes: [hero1, hero2])
        
        //Creamos el predicado que filtra por nombre
        let filter = #Predicate<MOHero> {hero in
            hero.name?.localizedStandardContains("Jose") == true
        }
        
        // WHEN: Aplicamos el filtro
        let heroes = sut.fetchHeroes(filter: filter)
        
        // THEN:
        XCTAssertEqual(heroes.count, 1)
        let hero = try XCTUnwrap(heroes.first)
        XCTAssertEqual(hero.name, hero2.name)
    }
    
    func testFetchLocations() throws {
        // GIVEN: Creamos un héroe y una ubicación
        let hero = createHero(with: "Vegeta")
        let location = createLocation(for: hero)
        
        sut.insert(heroes: [hero])
        sut.insert(locations: [location])
        
        // WHEN: Obtenemos las ubicaciones
        let fetchedLocations = sut.fetchLocations(filter: nil)
        
        // THEN: Verificamos que la ubicación se ha insertado correctamente
        XCTAssertEqual(fetchedLocations.count, 1)
        let fetchedLocation = try XCTUnwrap(fetchedLocations.first)
        XCTAssertEqual(fetchedLocation.identifier, location.id)
        XCTAssertEqual(fetchedLocation.latitude, location.latitude)
        XCTAssertEqual(fetchedLocation.longitude, location.longitude)
    }
    
    func testFetchTransformations() throws {
        // GIVEN: Creamos un héroe y una transformación
        let hero = createHero(with: "Frieza")
        let transformation = createTransformation(for: hero)
        
        sut.insert(heroes: [hero])
        sut.insert(transformations: [transformation])
        
        // WHEN: Obtenemos las transformaciones
        let fetchedTransformations = sut.fetchTransformations(filter: nil)
        
        // THEN: Verificamos que la transformación se ha insertado correctamente
        XCTAssertEqual(fetchedTransformations.count, 1)
        let fetchedTransformation = try XCTUnwrap(fetchedTransformations.first)
        XCTAssertEqual(fetchedTransformation.identifier, transformation.id)
        XCTAssertEqual(fetchedTransformation.name, transformation.name)
    }
    
    func testInsertLocations() throws {
        // GIVEN: Creamos locations y heroe e insertamos en bbdd
        let hero = createHero(with: "Perico")
        let location1 = createLocation(for: hero)
        
        sut.insert(heroes: [hero])
        sut.insert(locations: [location1])
        
        // WHEN: Obtenemos el heroe
        let fetchedHero = sut.fetchHeroes(filter: nil).first
        
        // THEN: Verificamos que el heroe tiene location y que las ubicaciones se han insertado
        XCTAssertNotNil(fetchedHero)
        let locations = fetchedHero?.locations

        XCTAssertEqual(locations?.count, 1)
        let fetchedLocation = try XCTUnwrap(locations?.first)
        XCTAssertEqual(fetchedLocation.identifier, location1.id)
        XCTAssertEqual(fetchedLocation.latitude, location1.latitude)
        XCTAssertEqual(fetchedLocation.longitude, location1.longitude)
        XCTAssertEqual(fetchedLocation.date, location1.date)
    }
    
    func testInsertTransformations() throws {
        // GIVEN:
        let hero = createHero(with: "Palotes")
        let transformation1 = createTransformation(for: hero)
        
        sut.insert(heroes: [hero])
        sut.insert(transformations: [transformation1])
        
        // WHEN:
        let fetchedHero = sut.fetchHeroes(filter: nil).first

        // THEN:
        XCTAssertNotNil(fetchedHero)
        let transformations = fetchedHero?.transformations
        
        XCTAssertEqual(transformations?.count, 1)
        let fetchedTransformation = try XCTUnwrap(transformations?.first)
        XCTAssertEqual(fetchedTransformation.identifier, transformation1.id)
        XCTAssertEqual(fetchedTransformation.name, transformation1.name)
    }
    
    func testClearBBDD() throws {
        // GIVEN: Insertamos un par de heroes, locations y transformations en la base
        let hero1 = createHero(with: "Goku")
       
        let location1 = createLocation(for: hero1)
      
        let transformation1 = createTransformation(for: hero1)


        sut.insert(heroes: [hero1])
        sut.insert(locations: [location1])
        sut.insert(transformations: [transformation1])

        // WHEN: Llamamos a clearBBDD
        let fetchedHero = sut.fetchHeroes(filter: nil).first
        sut.clearBBDD()

        // THEN: Verificamos que la base esté vacia
        XCTAssertEqual(sut.fetchHeroes(filter: nil).count, 0)
        XCTAssertEqual(sut.fetchLocations(filter: nil).count, 0)
        XCTAssertEqual(sut.fetchTransformations(filter: nil).count, 0)
    }
    
    // Helper function para crear heroes
    private func createHero(with name: String = "Name") -> ApiHero {
        ApiHero(id: UUID().uuidString,
                favorite: true,
                name: name,
                description: "description",
                photo: "photo")
    }
    
    // Helper para crear locations
    private func createLocation(for hero: ApiHero? = nil) -> ApiHeroLocation {
        ApiHeroLocation(id: UUID().uuidString,
                        longitude: "longitude",
                        latitude: "latitude",
                        date: "date",
                        hero: hero ?? createHero())
    }
    // Helper para crear transformaciones
    private func createTransformation(for hero: ApiHero? = nil) -> ApiHeroTransformation{
        ApiHeroTransformation(id: UUID().uuidString,
                              hero: hero ?? createHero(),
                              name: "name",
                              description: "description",
                              photo: "photo")
    }
    
   
    
    

}
// GIVEN:

// WHEN:

// THEN:

