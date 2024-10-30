//
//  WeatherViewController.swift
//  Weather
//
//  Created by Thomas Garayua on 10/29/24.
//

import UIKit
import SwiftUI
import Combine

class WeatherViewController: UIViewController {
    private var viewModel: WeatherViewModel
    private var cityTextField: UITextField!
    private var searchButton: UIButton!
    private var weatherInfoLabel: UILabel!

    // Add this property
    private var cancellables: Set<AnyCancellable> = []

    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        cityTextField = UITextField()
        cityTextField.placeholder = "Enter city name"
        cityTextField.borderStyle = .roundedRect
        cityTextField.translatesAutoresizingMaskIntoConstraints = false
        
        searchButton = UIButton(type: .system)
        searchButton.setTitle("Search", for: .normal)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.addTarget(self, action: #selector(searchWeather), for: .touchUpInside)
        
        weatherInfoLabel = UILabel()
        weatherInfoLabel.numberOfLines = 0
        weatherInfoLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(cityTextField)
        view.addSubview(searchButton)
        view.addSubview(weatherInfoLabel)

        // Layout constraints
        NSLayoutConstraint.activate([
            cityTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cityTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            cityTextField.widthAnchor.constraint(equalToConstant: 200),
            
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchButton.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 20),
            
            weatherInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherInfoLabel.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 20)
        ])
    }

    @objc private func searchWeather() {
        guard let city = cityTextField.text, !city.isEmpty else { return }
        viewModel.fetchWeather(for: city)
    }

    private func bindViewModel() {
        viewModel.$weatherResponse
            .sink { [weak self] response in
                if let response = response {
                    self?.weatherInfoLabel.text = "Weather in \(response.name): \(response.main.temp)°C"
                }
            }
            .store(in: &cancellables) // Store the cancellable

        viewModel.$errorMessage
            .sink { [weak self] error in
                if let error = error {
                    self?.weatherInfoLabel.text = "Error: \(error)"
                }
            }
            .store(in: &cancellables) // Store the cancellable
    }
}
