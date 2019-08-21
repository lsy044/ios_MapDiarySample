//
//  ViewController.swift
//
//  Created by JIN on 17/08/2019.
//  Copyright © 2019 sy. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //         For use in foreground
        //                self.locationManager.requestWhenInUseAuthorization()
        //                if CLLocationManager.locationServicesEnabled() {
        //                    locationManager.delegate = self
        //                    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //                    locationManager.startUpdatingLocation()
        //                } else {
        //                    print("Location service disabled");
        //                }
        ////                mapView.showsUserLocation = true
    }
    
    // MARK: - Location Delegate Methods
    // 새로운 위치정보 발생시 실행되는 메소드
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        if let locValue:CLLocationCoordinate2D = manager.location?.coordinate {
    //            print("locations = \(locValue.latitude) \(locValue.longitude)")
    //        }
    //
    //        let location = locations.last as! CLLocation
    //        // 위치정보 반환
    //        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    //        // MKCoordinateSpan -- 지도 scale
    //        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    ////        self.mapView.setRegion(region, animated: true)
    //        locationManager.stopUpdatingLocation()
    //
    //    }
    //
    //    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    //        print("Errors: " + error.localizedDescription)
    //    }
    //
    //
    //
}


