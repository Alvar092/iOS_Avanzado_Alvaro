//
//  HeroAnnotation.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 9/4/25.
//

import Foundation
import MapKit

// Custom annotation para poder diferenciarla de otras que hay en el map
// además podríamos tener varios tipos de annotations y asignrlas a cada una una vista disitinta
// MKAnnotation es un protocol que tenemos que implmentar y hereda de NSObject para que nos dé
// la implementaciones obligatorias de NSOBjectProtocol otro protocol que extiende MKAnnotation
class HeroAnnotation: NSObject,  MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil) {
        self.coordinate = coordinate
        self.title = title
    }
    
}
