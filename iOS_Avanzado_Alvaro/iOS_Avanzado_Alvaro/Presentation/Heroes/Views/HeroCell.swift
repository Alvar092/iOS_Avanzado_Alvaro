//
//  HeroCell.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 8/4/25.
//

import UIKit

class HeroCell: UICollectionViewCell {

    static let identifier = String(describing: HeroCell.self)
    
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var heroNamelb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(hero: Hero) {
        heroNamelb.text = hero.name
        loadImage(from: hero.photo)
    }

    
    private func loadImage(from url: String?) {
        guard let url = url, let url = URL(string: url) else { return }
        
        // Usamos URLSession para cargar la imagen de forma asíncrona
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.heroImage.image = image
            }
        }.resume()
    }
}
