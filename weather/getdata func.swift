//
//  readdata.swift
//  AI教你做運動
//
//  Created by HingTatTsang on 30/9/2022.
//

import Foundation
import CoreLocation
import SwiftUI
import WeatherKit
import Combine


class getdata {
    func getdefaultsdata(type: String) -> String {
        let defaults = UserDefaults.standard
        let type = defaults.string(forKey: "\(type)")
        return type ?? ""
    }
    func savedefaultsdata(type: String, data: String) -> Void {
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: "\(type)")
    }
    
    func getdefaultsdatabool(type: String) -> Bool {
        let defaults = UserDefaults.standard
        let type = defaults.bool(forKey: "\(type)")
        return type
    }
    func savedefaultsdatabool(type: String, data: Bool) -> Void {
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: "\(type)")
    }
    
    func getdefaultsdataint(type: String) -> Int {
        let defaults = UserDefaults.standard
        let type = defaults.integer(forKey: "\(type)")
        return type
    }
    func savedefaultsdataint(type: String, data: Int) -> Void {
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: "\(type)")
    }
    
    func getdata(date: String, datanum: Int) -> String {
        let defaults = UserDefaults.standard
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: date)
        
        let today = date
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd/MM/yyyy"
        let datedatanow = "\(formatter1.string(from: today ?? Date()))"
        let dataitem1 = defaults.string(forKey: "\(datedatanow)dataitem1")
        let dataitem2 = defaults.string(forKey: "\(datedatanow)dataitem2")
        let dataitem3 = defaults.string(forKey: "\(datedatanow)dataitem3")
        let dataitem4 = defaults.string(forKey: "\(datedatanow)dataitem4")
        //let dataholiday = defaults.bool(forKey: "\(datedatanow)dataholiday")
        let datacal1 = defaults.string(forKey: "\(datedatanow)datacal1")
        let datacal2 = defaults.string(forKey: "\(datedatanow)datacal2")
        let datacal3 = defaults.string(forKey: "\(datedatanow)datacal3")
        let datacal4 = defaults.string(forKey: "\(datedatanow)datacal4")
        
        //let holiday = dataholiday
        let item1 = dataitem1 ?? "N/A"
        let item2 = dataitem2 ?? "N/A"
        let item3 = dataitem3 ?? "N/A"
        let item4 = dataitem4 ?? "N/A"
        let cal1 = datacal1 ?? "N/A"
        let cal2 = datacal2 ?? "N/A"
        let cal3 = datacal3 ?? "N/A"
        let cal4 = datacal4 ?? "N/A"
        let alldata = ["(nil : N/A)", item1, item2, item3, item4, cal1, cal2, cal3, cal4]
        
        return alldata[datanum]
    }
    
    func username() -> String {
        if getdefaultsdata(type: "username") != "" {
            return getdefaultsdata(type: "username")
        } else {
            return "USERNAME"
        }
    }
    
    func savedata(date: String, datanum: Int, text: String) -> Void {
        let defaults = UserDefaults.standard
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: date)
        
        let today = date
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd/MM/yyyy"
        let datedatanow = "\(formatter1.string(from: today!))"
        
        if datanum == 1 {
            defaults.set(text, forKey: "\(datedatanow)dataitem1")
        }
        if datanum == 2 {
            defaults.set(text, forKey: "\(datedatanow)dataitem2")
        }
        if datanum == 3 {
            defaults.set(text, forKey: "\(datedatanow)dataitem3")
        }
        if datanum == 4 {
            defaults.set(text, forKey: "\(datedatanow)dataitem4")
        }
        if datanum == 5 {
            defaults.set(text, forKey: "\(datedatanow)datacal1")
        }
        if datanum == 6 {
            defaults.set(text, forKey: "\(datedatanow)datacal2")
        }
        if datanum == 7 {
            defaults.set(text, forKey: "\(datedatanow)datacal3")
        }
        if datanum == 8 {
            defaults.set(text, forKey: "\(datedatanow)datacal4")
        }
    }
    func notification(title: String, subtitle: String) -> Void {
        let content = UNMutableNotificationContent()
        content.title = "\(title)"
        content.body = "\(subtitle)"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func clear() -> Void {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}




class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentWeather: CurrentWeather?
    @Published var dailyForecasts: Forecast<DayWeather>?
    @Published var hourlyForecasts: Forecast<HourWeather>?
    @Published var location: CLLocation!
    @Published var cityName: String = "----"
    
    @Published var todayWeather: DayWeather?
    
    private let service = WeatherService.shared

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.location = location
        Task.detached {
            await self.weather(for: location)
            await self.hourlyForecast(for: location)
            await self.dailyForecast(for: location)
            
            await self.getTodayWeather()
        }
        getCityName(location)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func getCityName(_ location: CLLocation) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
            placemarks?.forEach { (placemark) in
                if let city = placemark.locality {
                    self.cityName = city
                }
            }
        })
    }
}

@MainActor
extension WeatherViewModel {
    func getTodayWeather() {
        self.dailyForecasts?.forEach({ weather in
            let diff = Calendar.current.dateComponents([.day], from: Date(), to: weather.date)
            if diff.day == 0 {
                self.todayWeather = weather
            }
        })
    }

    func weather(for location: CLLocation) async {
        let currentWeather = await Task.detached(priority: .userInitiated) {
            let forcast = try? await self.service.weather(
                for: location,
                including: .current)
            return forcast
        }.value
        self.currentWeather = currentWeather
    }
    
    func dailyForecast(for location: CLLocation) async {
        let dayWeather = await Task.detached(priority: .userInitiated) {
            let forcast = try? await self.service.weather(
                for: location,
                including: .daily)
            return forcast
        }.value
        self.dailyForecasts = dayWeather
    }
    
    func hourlyForecast(for location: CLLocation) async {
        let hourWeather = await Task.detached(priority: .userInitiated) {
            let forcast = try? await self.service.weather(
                for: location,
                including: .hourly)
            return forcast
        }.value
        self.hourlyForecasts = hourWeather
    }
}


struct DayForecast: Identifiable {
    var id = UUID().uuidString
    var day: String
    var farenheit: CGFloat
    var image: String
}

var forecast = [
    DayForecast(day: "Today", farenheit: 94,image: "sun.min"),
    DayForecast(day: "Wed", farenheit: 90,image: "cloud.sun"),
    DayForecast(day: "Tue", farenheit: 98,image: "cloud.sun.bolt"),
    DayForecast(day: "Thu", farenheit: 99,image: "sun.max"),
    DayForecast(day: "Fri", farenheit: 92,image: "cloud.sun"),
    DayForecast(day: "Sat", farenheit: 89,image: "cloud.sun"),
    DayForecast(day: "Sun", farenheit: 96,image: "sun.max"),
    DayForecast(day: "Mon", farenheit: 94,image: "sun.max"),
    DayForecast(day: "Tue", farenheit: 93,image: "cloud.sun.bolt"),
    DayForecast(day: "Wed", farenheit: 94,image: "sun.min"),
]
