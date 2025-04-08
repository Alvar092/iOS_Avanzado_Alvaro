//
//  SplashController.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import UIKit

class SplashController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let viewModel: SplashViewModel
    
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "SplashController", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var secureData = SecureDataProvider()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        viewModel.load()
    }
    
    private func bind() {
        viewModel.onStateChanged.bind { [weak self] newState in
            switch newState {
            case .loading:
                self?.setAnimation(true)
            case .error:
                self?.setAnimation(false)
            case .ready:
                self?.setAnimation(false)
                // dependiendo de si tenemos token de session navegamos a login o la pantallas de Heroes
                if self?.secureData.getToken() != nil {
//                    let heroesVC = HeroesController.build()
//                    self?.navigationController?.pushViewController(heroesVC, animated: false)
//                } else {
                    let loginController = LoginBuilder.build()
                    self?.navigationController?.pushViewController(loginController, animated: true)
                }
            }
        }
    }
    
    private func setAnimation(_ animating: Bool) {
        switch activityIndicator.isAnimating {
        case true where !animating:
            activityIndicator.stopAnimating()
        case false where animating:
            activityIndicator.startAnimating()
        default: break
        }
    }
}
