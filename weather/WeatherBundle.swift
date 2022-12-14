//
//  WeatherBundle.swift
//  Weather
//
//  Created by HingTatTsang on 14/12/2022.
//

import WidgetKit
import SwiftUI

@main
struct WeatherBundle: WidgetBundle {
    var body: some Widget {
        Weather()
        WeatherLiveActivity()
    }
}
