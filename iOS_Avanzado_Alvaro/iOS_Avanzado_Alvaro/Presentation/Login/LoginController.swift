//
//  LoginViewController.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 7/4/25.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    
    private let viewModel : LoginViewModel
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "LoginController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        viewModel.onStateChanged.bind { [weak self] state in
            switch state {
            case .error(let reason):
                self?.renderError(reason)
            case .loading:
                self?.renderLoading()
            case .success:
                self?.renderSuccess()
                let heroesVC = HeroesBuilder.build()
                self?.navigationController?.pushViewController(heroesVC, animated: true)
            }
        }
    }
    
    
    @IBAction func logInButtonTapped(_ sender: Any) {
        viewModel.login(userName: userNameField.text, password: passwordField.text)
      
    }
    
    
    
    // Manejamos los cambios de estado
    // Muestra la pantalla de heroes tras la autenticación exitosa
    private func renderSuccess() {
        activityIndicator.stopAnimating()
        loginButton.isHidden = false
        errorLabel.isHidden = true
//        present(HeroesListBuilder().build(), animated: true)
    }
    
    // Muestra el indiciador de carga mientras se procesa la autenticación
    private func renderLoading() {
        activityIndicator.startAnimating()
        loginButton.isHidden = true
        errorLabel.isHidden = true
    }
    
    // Fallo de autenticación¿?
    private func renderError(_ message: String) {
        activityIndicator.stopAnimating()
        loginButton.isHidden = false
        errorLabel.text = message
        errorLabel.isHidden = false
    }
}
