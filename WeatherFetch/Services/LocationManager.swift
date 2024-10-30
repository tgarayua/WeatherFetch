//
//  LocationManager.swift
//  Weather
//
//  Created by Thomas Garayua on 10/29/24.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate {
    @Published var location: CLLocationCoordinate2D?
    
    private var locationManager: CLLocationManager?
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        // Request location access
        locationManager?.requestWhenInUseAuthorization()
        
        // Start updating location
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        location = coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}


