//
//  WeatherFetchApp.swift
//  WeatherFetch
//
//  Created by Thomas Garayua on 10/30/24.
//

import SwiftUI

@main
struct WeatherFetchApp: App {
    @StateObject private var viewModel = WeatherViewModel(weatherService: WeatherService())

    var body: some Scene {
        WindowGroup {
            WeatherView()
                .environmentObject(viewModel) // Inject the view model into the environment
        }
    }
}
