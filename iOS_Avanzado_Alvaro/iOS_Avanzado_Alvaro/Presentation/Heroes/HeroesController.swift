//
//  HeroesController.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 8/4/25.
//

import UIKit

enum HeroesSections {
    case main
}

final class HeroesController: UIViewController {
    
    
    
    typealias DataSource = UICollectionViewDiffableDataSource<HeroesSections, Hero>
    typealias CellRegistration = UICollectionView.CellRegistration<HeroCell, Hero>
    
    // Outlet para el collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel: HeroesViewModel
    private var dataSource: DataSource?
    
    init(viewModel: HeroesViewModel = HeroesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HeroesController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenStatesChangesInViewModel()
        configureCollectionView()
        viewModel.loadData()
    }
    
    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 10
        collectionView.collectionViewLayout = layout
        
        collectionView.delegate = self
        
        // Usamos un CellRegistration para crear las celdas  una ventaja que tiene es que si usamos el objeto como
        // identificador ya nos viene en el handler y no necesitamos acceder a él por su indexPath
        let nib = UINib(nibName: HeroCell.identifier, bundle: nil)
        let cellRegistration = CellRegistration(cellNib: nib) { cell, indexPath, hero in
            cell.configure(hero: hero)
        }
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, hero in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: hero)
        })
    }
    
    func listenStatesChangesInViewModel() {
        viewModel.stateChanged = { [weak self] state in
            switch state {
            case .dataUpdated:
                var snapshot = NSDiffableDataSourceSnapshot<HeroesSections, Hero>()
                snapshot.appendSections([.main])
                snapshot.appendItems(self?.viewModel.fetchHeroes() ?? [], toSection: .main)
                self?.dataSource?.applySnapshotUsingReloadData(snapshot)
                
            case .errorLoadingHeroes(error: let error):
                print(error)
            }
        }
    }
    
    // Al pulsar el boton de logout limpiamos la base de datos y
    // volvemos a pedir los heroes al caso de uso.
    @IBAction func logoutTapped() {
        viewModel.performLogout()
        navigationController?.popToRootViewController(animated: true)
    }
}

extension HeroesController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout ,sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 10
        let totalSpacing = spacing * 3
        let itemWidth = ((collectionView.bounds.width - totalSpacing)/2)
        return CGSize(width: itemWidth, height: 150)
    }
    
    
    // Cuando se seleccione un heroe
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let hero = viewModel.heroWith(index: indexPath.row) else {
            return
        }
        let viewModel = HeroDetailViewModel(hero: hero)
        let heroDetail = HeroDetailController(viewModel: viewModel)
        navigationController?.pushViewController(heroDetail, animated: true)
    }
        
    
}


