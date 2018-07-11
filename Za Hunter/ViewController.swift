//
//  ViewController.swift
//  Za Hunter
//
//  Created by Jean Cho on 7/11/18.
//  Copyright © 2018 Jean Cho. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var region = MKCoordinateRegion()
    var mapItems = [MKMapItem]()
    var selectedMapItem = MKMapItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        
    }
    
    //zooms in on current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude) //center
        let span = MKCoordinateSpanMake(0.025, 0.025) //span
        let region = MKCoordinateRegionMake(center, span) //the region is the distance of the span from the center
        mapView.setRegion(region, animated: true)
    }
    
    //find all locations on map w key word pizza and name them w their names
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "pizza"
        request.region = region
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            if let response = response {
                for mapItem in response.mapItems {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = mapItem.placemark.coordinate
                    annotation.title = mapItem.name
                    self.mapView.addAnnotation(annotation)
                    self.mapItems.append(mapItem)
                }
            }
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
        }
    
    //programatically calling segue when the accessory is tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "ShowLocationDetailsSegue", sender: nil)
    }
  
    //if the mapItem's location matches up w the view's location holder, then the mapItem is correct. Pass information from pizza website thingy to pinpoint
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for mapItem in mapItems {
            if mapItem.placemark.coordinate.latitude == view.annotation?.coordinate.latitude && mapItem.placemark.coordinate.longitude == view.annotation?.coordinate.longitude {
                selectedMapItem = mapItem
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LocationDetailsViewController {
            destination.selectedMapItem = selectedMapItem
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

