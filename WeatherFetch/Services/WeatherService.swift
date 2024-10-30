//
//  WeatherService.swift
//  Weather
//
//  Created by Thomas Garayua on 10/29/24.
//

import Foundation
import CoreLocation

class WeatherService {
    let apiKey = "36fb93636d7b3adc0b9881e208eb6f8c"
    let baseURL = "https://api.openweathermap.org/data/2.5/weather"

    // Existing method for fetching weather by city name
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "\(baseURL)?q=\(city),US&appid=\(apiKey)&units=metric"  // Ensure correct format with country code
        guard let url = URL(string: urlString) else {
            completion(.failure(WeatherError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(WeatherError.noData))
                return
            }
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // New method for fetching weather by coordinates
    func fetchWeather(for location: CLLocationCoordinate2D, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "\(baseURL)?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            completion(.failure(WeatherError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(WeatherError.noData))
                return
            }
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

// MARK: - WeatherError
enum WeatherError: Error {
    case invalidURL
    case noData
}

