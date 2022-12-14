//
//  ForecastView.swift
//  Weather
//
//  Created by Anh Nguyen on 22/06/2022.
//

import SwiftUI
import WeatherKit

struct HourForecastItemView: View {
    var hourWeather: HourWeather
    
    var timeFormat: Date.FormatStyle {
        Date.FormatStyle().hour()
    }
    var timeFormat2: Date.FormatStyle {
        Date.FormatStyle().day()
    }

    var body: some View {
        if hourWeather.date > Date() && hourWeather.date < Date().addingTimeInterval(24 * 60 * 60) {
            VStack(spacing: 4) {
                Text(hourWeather.date, format: timeFormat)
                    .font(.callout.bold())
                    .foregroundStyle(.white)
                Image(systemName: hourWeather.symbolName)
                    .font(.title2)
                    .symbolVariant(.fill)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle((hourWeather.isDaylight && (hourWeather.condition == .mostlyClear || hourWeather.condition == .clear)) ? .yellow : .white)
                    .frame(height: 30)
                
                Text(hourWeather.temperature.formatted(.measurement(width: .abbreviated, usage: .weather)))
                    .font(.callout.bold())
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 10)
        }
    }
}
