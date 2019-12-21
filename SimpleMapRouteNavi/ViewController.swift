//
//  ViewController.swift
//  SimpleMapRouteNavi
//
//  Created by FumiyaTanaka on 2019/12/21.
//  Copyright © 2019 FumiyaTanaka. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var tableView: UITableView!
    
    var placemarks: [MKPlacemark] = []
    
    private var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager.delegate = self
        searchBar.delegate = self
        hideTableView(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default:
                break
            }
        }
    }
    
    private func searchLocation(with text: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let error = error {
                fatalError("\(error)")
            }
            guard let response = response else { return }
            self.placemarks = response.mapItems.map { $0.placemark }
            DispatchQueue.main.async {
                self.mapView.removeOverlays(self.mapView.overlays)
                self.tableView.reloadData()
                self.hideTableView(false)
            }
        }
    }
    
    func hideTableView(_ shouldHide: Bool) {
        
        let beforeAlpha = tableView.alpha
        
        UIView.animate(withDuration: 1.0, animations: {
            self.tableView.alpha = abs(1 - beforeAlpha)
        }, completion: { _ in
            self.tableView.isHidden = shouldHide
        })
        
    }
    
    func showDirection(from source: MKPlacemark, to destination: MKPlacemark) {
        let request = MKDirections.Request()
        request.destination = MKMapItem(placemark: destination)
        request.source = MKMapItem(placemark: source)
        request.requestsAlternateRoutes = true
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error = error {
                fatalError("\(error)")
            }
            guard let response = response, let route = response.routes.first else { return }
            
            DispatchQueue.main.async {
                self.mapView.addOverlay(route.polyline)
                self.hideTableView(true)
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MapTableViewCell
        cell.configure(placemarks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placemarks.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destination = placemarks[indexPath.row]
        guard let coordinate = locationManager.location?.coordinate else { return }
        let source = MKPlacemark(coordinate: coordinate)
        showDirection(from: source, to: destination)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .gray
            renderer.lineWidth = 3.0
            return renderer
        }
        return MKOverlayRenderer()
    }
}

extension ViewController: MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        searchLocation(with: text)
    }
    
}
