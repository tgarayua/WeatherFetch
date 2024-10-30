//
//  WeatherView.swift
//  WeatherFetch
//
//  Created by Thomas Garayua on 10/30/24.
//

import SwiftUI

struct WeatherView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var cityText: String = "" // State to store user input

    var body: some View {
        VStack(spacing: 20) {
            // City Input TextField
            TextField("Enter city", text: $cityText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Fetch Button
            Button(action: {
                viewModel.fetchWeather(for: cityText)
            }) {
                Text("Get Weather")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            // Display Weather Information
            if let weatherResponse = viewModel.weatherResponse {
                Text(weatherResponse.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack {
                    Image(systemName: iconForCondition(weatherResponse.weather.first?.main ?? ""))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    
                    Text("\(String(format: "%.1f", weatherResponse.main.temp))°C")
                        .font(.system(size: 60))
                        .fontWeight(.thin)
                }

                Text(weatherResponse.weather.first?.description.capitalized ?? "Condition")
                    .font(.title2)
                    .foregroundColor(.gray)

                VStack(alignment: .leading) {
                    Text("Humidity: \(weatherResponse.main.humidity)%")
                    Text("Wind Speed: \(String(format: "%.1f", weatherResponse.wind.speed)) km/h")
                }
                .font(.headline)
                .padding()
                .background(Color(UIColor.systemGray5))
                .cornerRadius(10)
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
        WeatherView().environmentObject(WeatherViewModel(weatherService: WeatherService()))
    }
}
