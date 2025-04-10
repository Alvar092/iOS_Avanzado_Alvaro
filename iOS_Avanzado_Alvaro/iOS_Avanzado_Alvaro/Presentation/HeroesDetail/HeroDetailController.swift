//
//  HeroDetailController.swift
//  iOS_Avanzado_Alvaro
//
//  Created by Álvaro Entrena Casas on 9/4/25.
//

import UIKit
import MapKit
import CoreLocation

enum HeroTransformationSection: Hashable {
    case main
}

class HeroDetailController: UIViewController {
    
    @IBOutlet weak var heroNameLabel: UILabel!
    @IBOutlet weak var heroDescriptionTextView: UITextView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var transformationsCollectionView: UICollectionView!
    
    private var viewModel: HeroDetailViewModel
    private var dataSource: DataSource?
    private var locationManager: CLLocationManager = .init()
    
    init(viewModel: HeroDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HeroDetailController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateView()
        configureCollectionView()
        listenStatesChangesInViewModel()
        checkLocationAuthorizationStatus()
        viewModel.loadTransformations()
        viewModel.loadData()
    }
    
    // Configuramos el mapView
    private func configurateView() {
        mapView.delegate = self
        mapView.pitchButtonVisibility = .visible
        mapView.showsUserLocation = true
        heroNameLabel.text = viewModel.hero.name
        heroDescriptionTextView.text = viewModel.hero.description
    }
    
    func listenStatesChangesInViewModel() {
        viewModel.stateChanged = { [weak self] state in
            switch state {
            case .locationsUpdated:
                self?.addAnnotationsToMap()
            case .errorLoadingLocation(error: let error):
                debugPrint(error.localizedDescription)
            case .transformationsUpdated:
                self?.applySnapshot()
            case .errorLoadingTransformations(error: let error):
                print(error)
            }
        }
    }
    
    func addAnnotationsToMap() {
        let annotations = mapView.annotations
        // Elimina las anotaciones ya existentes.
        if !annotations.isEmpty {
            mapView.removeAnnotations(annotations)
        }
        // Agregamos anotaciones obtenidas del viewModel.
        mapView.addAnnotations(viewModel.getHeroLocations())
        
        // Ajusta la region del mapa para que se enfoque en la primera anotacion.
        if let annotation = mapView.annotations.sorted(by: {$0.coordinate.latitude > $1.coordinate.latitude}).first {
            mapView.region = MKCoordinateRegion(center: annotation.coordinate,
                                                latitudinalMeters: 100_000,
                                                longitudinalMeters: 100_000)
        }
    }
    
    private func checkLocationAuthorizationStatus() {
        // Verificamos el estado de autorización de la ubicación
        
        let status = locationManager.authorizationStatus
        
        switch status {
        // Si no hay autorizacion, la solicita
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        //Si esta restringido o denegado, desactiva la visualizacion del user
        case .restricted, .denied:
            mapView.showsUserLocation = false
        // Si esta autorizado, muestra el boton para rastrear la ubi y actualiza
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserTrackingButton = true
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
}

extension HeroDetailController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        // Si el tipo es HeroAnnotation se reutiliza una vista de anotación
        guard annotation is HeroAnnotation else {
            return nil
        }
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: HeroAnnotationView.identifier) {
            return view
        }
        // Si no existe una vista reutilizable creamos una
        return HeroAnnotationView(annotation: annotation, reuseIdentifier: HeroAnnotationView.identifier)
    }
}





extension HeroDetailController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    typealias DataSource = UICollectionViewDiffableDataSource<HeroTransformationSection, HeroTransformation>
    typealias CellRegistration = UICollectionView.CellRegistration<TransformationCell, HeroTransformation>
    
    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
        
        transformationsCollectionView.collectionViewLayout = layout
        
        transformationsCollectionView?.delegate = self
        
        transformationsCollectionView.isPagingEnabled = true
        transformationsCollectionView.showsHorizontalScrollIndicator = false
        
        let nib = UINib(nibName: TransformationCell.identifier, bundle: nil)
        let cellRegistration: CellRegistration = CellRegistration(cellNib: nib) { cell, indexPath, transformation in
            cell.configureCell(transformation: transformation)
        }
        dataSource = DataSource(collectionView: transformationsCollectionView, cellProvider: { collectionView, indexPath, transformation in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: transformation)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout ,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    private func applySnapshot() {
        guard let dataSource = self.dataSource else {
            return
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<HeroTransformationSection, HeroTransformation>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.transformations, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let transformation = viewModel.transformationWith(index: indexPath.row) else {
            return
        }
        let transformationDetail = TransformationDetailController(nibName: TransformationDetailController.identifier, bundle: nil)
        transformationDetail.transformation = transformation
        transformationDetail.modalPresentationStyle = .pageSheet
        present(transformationDetail, animated: true, completion: nil)
    }
}
