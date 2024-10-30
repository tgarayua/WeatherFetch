//
//  WeatherViewController.swift
//  Weather
//
//  Created by Thomas Garayua on 10/29/24.
//

import UIKit
import Combine

class WeatherViewController: UIViewController {
    private var viewModel: WeatherViewModel
    private var cityTextField: UITextField!
    private var searchButton: UIButton!
    private var weatherInfoLabel: UILabel!
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

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cityTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cityTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            cityTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchButton.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 20),

            weatherInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherInfoLabel.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 20),
            weatherInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weatherInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
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
            .store(in: &cancellables)

        viewModel.$errorMessage
            .sink { [weak self] error in
                if let error = error {
                    self?.weatherInfoLabel.text = "Error: \(error)"
                }
            }
            .store(in: &cancellables)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.setupConstraints() // Reapply constraints to update layout
        }, completion: nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Handle any additional updates when size class changes
    }
}
