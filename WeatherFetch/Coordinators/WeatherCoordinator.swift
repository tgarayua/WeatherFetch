//
//  WeatherCoordinator.swift
//  Weather
//
//  Created by Thomas Garayua on 10/29/24.
//

import UIKit

class WeatherCoordinator {
    var navigationController: UINavigationController
    var weatherViewModel: WeatherViewModel

    init(navigationController: UINavigationController, weatherService: WeatherService) {
        self.navigationController = navigationController
        self.weatherViewModel = WeatherViewModel(weatherService: WeatherService(), locationManager: LocationManager())
    }
    
    func start() {
        let weatherViewController = WeatherViewController(viewModel: weatherViewModel)
        navigationController.pushViewController(weatherViewController, animated: false)
    }
}
