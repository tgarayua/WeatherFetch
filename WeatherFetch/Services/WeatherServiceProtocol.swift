//
//  WeatherServiceProtocol.swift
//  WeatherFetch
//
//  Created by Thomas Garayua on 10/30/24.
//

import CoreLocation

protocol WeatherServiceProtocol {
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void)
    func fetchWeather(for location: CLLocationCoordinate2D, completion: @escaping (Result<WeatherResponse, Error>) -> Void)
}
