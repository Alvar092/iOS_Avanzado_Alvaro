//
//  TransformationCollectionViewCell.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 9/4/25.
//

import UIKit

class TransformationCell: UICollectionViewCell {

    static let identifier = String(describing: TransformationCell.self)
    
    @IBOutlet weak var transformationImageView: UIImageView!
    
    @IBOutlet weak var transformationNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(transformation: HeroTransformation) {
        transformationNameLabel.text = transformation.name
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
