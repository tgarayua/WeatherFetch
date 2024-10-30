//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Thomas Garayua on 10/29/24.
//

import Foundation
import Combine
import CoreLocation

class WeatherViewModel: ObservableObject {
    @Published var weatherResponse: WeatherResponse?
    @Published var errorMessage: String?
    
    private var weatherService: WeatherService
    private var locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    init(weatherService: WeatherService) {
        self.weatherService = weatherService
        
        // Listen for location updates
        locationManager.$location
            .compactMap { $0 } // Only pass non-nil locations
            .sink { [weak self] location in
                self?.fetchWeather(for: location) // Pass CLLocationCoordinate2D
            }
            .store(in: &cancellables)
        
        // Auto-load last searched city if available
        if let lastCity = UserDefaults.standard.string(forKey: "lastCity") {
            fetchWeather(for: lastCity)
        }
    }
    
    // New method to fetch weather using coordinates
    func fetchWeather(for location: CLLocationCoordinate2D) {
        weatherService.fetchWeather(for: location) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Weather fetched for coordinates: \(location): \(response)") // Debugging
                    self?.weatherResponse = response
                    self?.errorMessage = nil
                case .failure(let error):
                    print("Failed to fetch weather for coordinates: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    self?.weatherResponse = nil
                }
            }
        }
    }

    // Existing method for fetching weather by city name
    func fetchWeather(for city: String) {
        weatherService.fetchWeather(for: city) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Weather fetched for \(city): \(response)") // Debugging
                    self?.weatherResponse = response
                    UserDefaults.standard.set(city, forKey: "lastCity")
                    self?.errorMessage = nil
                case .failure(let error):
                    print("Failed to fetch weather for \(city): \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    self?.weatherResponse = nil
                }
            }
        }
    }
}

