//
//  WeatherContentView.swift
//  weather
//
//  Created by HingTatTsang on 11/12/2022.
//

import SwiftUI
import WeatherKit
import MapKit
import CoreLocation
import Contacts

struct WeatherContentView: View {
    @State var text = ["--", "questionmark", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--", "--"]
    @State var weathertemp = "loading..."
    @State var place = ["", ""]
    @State var location = CLLocation(latitude: 22.302711, longitude: 114.177216)
    @State var daily: Forecast<DayWeather>?
    @State var hour2: Forecast<HourWeather>?
    @State var loaded = false
    var body: some View {
        Group {
            if loaded {
                VStack {
                    ScrollView {
                        ZStack {
                            MapContentView(region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude,longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)))
                                .frame(height: 200)
                            
                        }
                        
                        VStack {
                            VStack {
                                HStack {
                                    Text(Image(systemName: text[1]))
                                        .font(.title)
                                    Text(text[10])
                                        .font(.title)
                                    Spacer()
                                    
                                    Text(text[0])
                                        .font(.title)
                                }
                                
                            }
                            .padding()
                            
                            VStack {
                                if let forecasts = hour2 {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(forecasts, id: \.date) { weather in
                                                HourForecastItemView(hourWeather: weather)
                                            }
                                            
                                        }
                                    }
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(25)
                                }
                            }
                            .padding(.horizontal)
                            
                            NavigationLink(destination: DailyForecastView(dailyForecast: daily!), label: {
                                HStack {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Text("10天天氣預報")
                                                .bold()
                                                .foregroundColor(.white)
                                                .padding()
                                            Spacer()
                                        }
                                    }
                                    
                                }
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(20)
                                .padding(.vertical, 2)
                                .padding(.horizontal)
                            })
                            
                            VStack {
                                HStack {
                                    TextBox(text1: "紫外線", text2: $text[3], size2: 50)
                                    TextBox(text1: "濕度", text2: $text[2], size2: 50, showtextlater: "%")
                                }
                                HStack {
                                    TextBox(text1: "體感溫度", text2: $text[6], size2: 30, showtextlater: "°C")
                                    TextBox(text1: "能見度", text2: $text[7])
                                }
                                HStack {
                                    TextnBox(deg: $text[5])
                                    TextBox(text1: "風速", text2: $text[4], size2: 20)
                                }
                                HStack {
                                    TextBox(text1: "雲量", text2: $text[8], size2: 50, showtextlater: "%")
                                    TextBox(text1: "氣壓", text2: $text[9], size2: 20)
                                }
                            }
                            
                            
                        }
                        appleView()
                    }
                    
                    
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .bottom, endPoint: .top))
                    
                }
                .navigationTitle("\(place[0])").accentColor(.black)
                
            } else {
                ProgressView()
            }
        }
        
        .onAppear() {
            getReverSerGeoLocation(location: location)
        }
        .task {
            async let a = getwerather()
            
            await text[0] = a.currentWeather.temperature.formatted()
            await text[1] = a.currentWeather.symbolName
            await text[2] = String(Int(a.currentWeather.humidity*100))
            await text[3] = String(Int(a.currentWeather.uvIndex.value.formatted())!)
            await text[4] = String(a.currentWeather.wind.speed.formatted())
            await text[5] = a.currentWeather.wind.direction.formatted()
            await text[6] = a.currentWeather.apparentTemperature.value.formatted()
            await text[7] = a.currentWeather.visibility.formatted()
            await text[8] = String(Int(Float(a.currentWeather.cloudCover.formatted())!*100.0))
            await text[9] = a.currentWeather.pressure.formatted()
            await text[10] = a.currentWeather.condition.description
            await text[11] = a.hourlyForecast.forecast.description
            await daily = a.dailyForecast
            await hour2 = a.hourlyForecast
            
            loaded = true
//                await text[11] = a
        }
    }
    
    func getwerather() async -> Weather {
        let weatherService = WeatherService()
        let syracuse = location
        let weather = try! await weatherService.weather(for: syracuse)
        return weather
        
    }
    func getReverSerGeoLocation(location : CLLocation) -> Void {
        
        CLGeocoder().reverseGeocodeLocation(location) {
            placemarks , error in
            
            if error == nil && placemarks!.count > 0 {
                guard let placemark = placemarks?.last else {
                    return
                }
                //                print(placemark.thoroughfare)
                //                print(placemark.subThoroughfare)
                //                print("postalCode :-",placemark.postalCode)
                //                print("City :-",placemark.locality)
                //                print("subLocality :-",placemark.subLocality)
                //                print("subAdministrativeArea :-",placemark.subAdministrativeArea)
                //                print("Country :-",placemark.country)
                place[0] = "\(placemark.locality ?? "Error !")"
                place[1] = "\(placemark.country ?? "")"
            }
        }
    }

}


struct WeatherContentView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherContentView()
    }
}
