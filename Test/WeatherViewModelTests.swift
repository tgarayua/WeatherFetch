//
//  WeatherViewModelTests.swift
//
//  Created by Thomas Garayua on 10/30/24.
//

import XCTest
import Combine
import CoreLocation
@testable import WeatherFetch

class WeatherViewModelTests: XCTestCase {
    private var viewModel: WeatherViewModel!
    private var mockWeatherService: MockWeatherService!
    private var mockLocationManager: MockLocationManager!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockWeatherService = MockWeatherService()
        mockLocationManager = MockLocationManager()
        viewModel = WeatherViewModel(weatherService: <#WeatherService#>, locationManager: mockLocationManager)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockWeatherService = nil
        mockLocationManager = nil
        cancellables = []
        super.tearDown()
    }

    func testFetchWeatherForCity_Success() {
        // Given
        let expectedCity = "London"
        let expectedTemperature = 25.0
        mockWeatherService.mockResponse = WeatherResponse(
            coord: Coordinates(lon: 0, lat: 0),
            weather: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
            main: Main(temp: expectedTemperature, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0),
            wind: Wind(speed: 0, deg: 0),
            name: expectedCity
        )

        // When
        viewModel.fetchWeather(for: expectedCity)

        // Then
        viewModel.$weatherResponse
            .sink { response in
                XCTAssertEqual(response?.name, expectedCity)
                XCTAssertEqual(response?.main.temp, expectedTemperature)
            }
            .store(in: &cancellables)
    }

    func testFetchWeatherForCity_Failure() {
        // Given
        let expectedError = "City not found"
        mockWeatherService.mockError = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: expectedError])

        // When
        viewModel.fetchWeather(for: "InvalidCity")

        // Then
        viewModel.$errorMessage
            .sink { errorMessage in
                XCTAssertEqual(errorMessage, expectedError)
            }
            .store(in: &cancellables)
    }

    func testLoadLastSearchedCity() {
        // Given
        let expectedCity = "Paris"
        UserDefaults.standard.set(expectedCity, forKey: "lastSearchedCity")

        // When
        viewModel.loadLastSearchedCity()

        // Then
        XCTAssertEqual(viewModel.searchText, expectedCity)
    }

    func testFetchWeatherForLocation_Success() {
        // Given
        let location = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522) // Paris coordinates
        let expectedCity = "Paris"
        let expectedTemperature = 20.0
        mockWeatherService.mockResponse = WeatherResponse(
            coord: Coordinates(lon: location.longitude, lat: location.latitude),
            weather: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
            main: Main(temp: expectedTemperature, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0),
            wind: Wind(speed: 0, deg: 0),
            name: expectedCity
        )

        // When
        viewModel.fetchWeather(for: location)

        // Then
        viewModel.$weatherResponse
            .sink { response in
                XCTAssertEqual(response?.name, expectedCity)
                XCTAssertEqual(response?.main.temp, expectedTemperature)
            }
            .store(in: &cancellables)
    }
}

// Mock Services
class MockWeatherService: WeatherServiceProtocol {
    var mockResponse: WeatherResponse?
    var mockError: Error?

    func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        if let response = mockResponse {
            completion(.success(response))
        } else if let error = mockError {
            completion(.failure(error))
        }
    }

    func fetchWeather(for location: CLLocationCoordinate2D, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        if let response = mockResponse {
            completion(.success(response))
        } else if let error = mockError {
            completion(.failure(error))
        }
    }
}

class MockLocationManager: LocationManager {
    override var currentLocation: CLLocationCoordinate2D? {
        didSet {
            // Send the updated location through the publisher
            locationPublisher.send(currentLocation)
        }
    }

    override func requestLocationPermission() {
        // Call super to maintain the original functionality
        super.requestLocationPermission()
        permissionStatusPublisher.send(true) // Mock permission granted
    }
}

