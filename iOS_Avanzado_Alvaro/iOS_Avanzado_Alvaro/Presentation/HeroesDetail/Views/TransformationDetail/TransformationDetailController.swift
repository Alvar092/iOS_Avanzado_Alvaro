//
//  TransformationDetailController.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 10/4/25.
//

import UIKit

class TransformationDetailController: UIViewController {

    static let identifier = String(describing: TransformationDetailController.self)
    
    var transformation: HeroTransformation?
    
    @IBOutlet weak var transformationNameLabel: UILabel!
    @IBOutlet weak var transformationImageView: UIImageView!
    @IBOutlet weak var transformationDescriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        guard let transformation = transformation else {return}
        
        transformationNameLabel.text = transformation.name
        transformationDescriptionTextView.text = transformation.description
        loadImage(from: transformation.photo)
    }
    
    private func loadImage(from url: String?) {
        guard let url = url, let url = URL(string: url) else { return }
        
        // Usamos URLSession para cargar la imagen de forma asíncrona
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.transformationImageView.image = image
            }
        }.resume()
    }
}
