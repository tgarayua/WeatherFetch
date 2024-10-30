//
//  LocationManager.swift
//  Weather
//
//  Created by Thomas Garayua on 10/29/24.
//

import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager: CLLocationManager?
    
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var locationDenied: Bool = false
    
    // Create subjects for location updates and permission status
    var locationPublisher = PassthroughSubject<CLLocationCoordinate2D?, Never>()
    var permissionStatusPublisher = PassthroughSubject<Bool, Never>()
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        requestLocationPermission()
    }
    
    func requestLocationPermission() {
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first?.coordinate {
            self.currentLocation = location
            locationPublisher.send(location)  // Send location update
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            locationDenied = true
            permissionStatusPublisher.send(false) // Notify permission denied
        } else if status == .authorizedWhenInUse {
            startUpdatingLocation()
            permissionStatusPublisher.send(true) // Notify permission granted
        }
    }
}
