//
//  HeroAnnotationView.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 9/4/25.
//

import Foundation
import MapKit


// Custom view para mostrar nuestras annotations
class HeroAnnotationView: MKAnnotationView {
    
    static let identifier = String(describing: HeroAnnotationView.self)
    
    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.canShowCallout = true   // Permite mostrar un título y subtitulo al ser seleccionada
        self.backgroundColor = .clear
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configura el UI de la vista, creamos un imageView y se lo añade como subvista
    private func setupUI() {
        let imagView = UIImageView(image: UIImage(resource: .bolaDragon))
        self.addSubview(imagView)
        imagView.frame = self.bounds
    }
}
