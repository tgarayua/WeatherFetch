//
//  WeatherView.swift
//  WeatherFetch
//
//  Created by Thomas Garayua on 10/30/24.
//

import SwiftUI

struct WeatherView: View {
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var cityText: String = ""

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                TextField("Enter city", text: $cityText, onCommit: {
                    fetchWeather()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

                Button(action: {
                    fetchWeather()
                }) {
                    Text("Get Weather")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                if let weatherResponse = viewModel.weatherResponse {
                    if geometry.size.width > geometry.size.height {
                        // Landscape layout
                        HStack {
                            weatherInfoColumn(for: weatherResponse, in: geometry)
                            Divider()
                            weatherDetailsColumn(for: weatherResponse)
                        }
                    } else {
                        // Portrait layout
                        VStack {
                            weatherInfoColumn(for: weatherResponse, in: geometry)
                            weatherDetailsColumn(for: weatherResponse)
                        }
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(15)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity) // Make it responsive to width
            .onAppear {
                if let lastCity = UserDefaults.standard.string(forKey: "lastSearchedCity") {
                    cityText = lastCity
                }
            }
        }
        .padding()
    }

    private func weatherInfoColumn(for weatherResponse: WeatherResponse, in geometry: GeometryProxy) -> some View {
        VStack {
            Text(weatherResponse.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .minimumScaleFactor(0.5) // Allow text to shrink

            HStack {
                Image(systemName: iconForCondition(weatherResponse.weather.first?.main ?? ""))
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width > geometry.size.height ? 100 : 80, height: geometry.size.width > geometry.size.height ? 100 : 80)

                Text("\(String(format: "%.1f", weatherResponse.main.temp))°C")
                    .font(.system(size: geometry.size.width > geometry.size.height ? 80 : 60))
                    .fontWeight(.thin)
            }

            Text(weatherResponse.weather.first?.description.capitalized ?? "Condition")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
    }

    private func weatherDetailsColumn(for weatherResponse: WeatherResponse) -> some View {
        VStack(alignment: .leading) {
            Text("Humidity: \(weatherResponse.main.humidity)%")
            Text("Wind Speed: \(String(format: "%.1f", weatherResponse.wind.speed)) km/h")
        }
        .font(.headline)
        .padding()
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
    }

    private func fetchWeather() {
        viewModel.fetchWeather(for: cityText)
    }

    private func iconForCondition(_ condition: String) -> String {
        switch condition {
        case "Clear":
            return "sun.max.fill"
        case "Clouds":
            return "cloud.fill"
        case "Rain":
            return "cloud.rain.fill"
        case "Snow":
            return "snow"
        default:
            return "questionmark"
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView().environmentObject(WeatherViewModel(weatherService: WeatherService(), locationManager: LocationManager()))
            .previewDevice("iPhone 14")
        WeatherView().environmentObject(WeatherViewModel(weatherService: WeatherService(), locationManager: LocationManager()))
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
    }
}
