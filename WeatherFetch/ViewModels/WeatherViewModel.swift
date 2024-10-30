//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Thomas Garayua on 10/29/24.
//

import Combine
import CoreLocation

class WeatherViewModel: ObservableObject {
    @Published var weatherResponse: WeatherResponse?
    @Published var errorMessage: String?
    @Published var searchText: String = "" // Add a property for search text

    private var weatherService: WeatherService
    private var locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()

    init(weatherService: WeatherService, locationManager: LocationManager) {
        self.weatherService = weatherService
        self.locationManager = locationManager

        // Observe the currentLocation property
        locationManager.$currentLocation
            .sink { [weak self] location in
                // Fetch weather for current location if the user has granted permission
                if let location = location {
                    self?.fetchWeather(for: location)
                }
            }
            .store(in: &cancellables)

        // Observe locationDenied to handle when access is denied
        locationManager.$locationDenied
            .sink { [weak self] denied in
                if denied {
                    self?.loadLastSearchedCity() // Load last searched city if location access is denied
                }
            }
            .store(in: &cancellables)

        // Always load last searched city on app launch
        loadLastSearchedCity()

        // Request permission for location access (only if not previously granted)
        if isFirstLaunch() {
            locationManager.requestLocationPermission()
        }
    }

    private func isFirstLaunch() -> Bool {
        // Check UserDefaults to determine if the app is being launched for the first time
        return !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    }

    func fetchWeather(for city: String) {
        // Save the city to UserDefaults
        UserDefaults.standard.set(city, forKey: "lastSearchedCity")
        searchText = city // Set the search text to the city name

        weatherService.fetchWeather(for: city) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.weatherResponse = response
                    self?.errorMessage = nil
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func fetchWeather(for location: CLLocationCoordinate2D) {
        weatherService.fetchWeather(for: location) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.weatherResponse = response
                    self?.errorMessage = nil
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func loadLastSearchedCity() {
        if let lastSearchedCity = UserDefaults.standard.string(forKey: "lastSearchedCity") {
            fetchWeather(for: lastSearchedCity) // Fetch weather for the last searched city
            searchText = lastSearchedCity // Update the search text
        }
    }

    func setHasLaunched() {
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
    }
}
