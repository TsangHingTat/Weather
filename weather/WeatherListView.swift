//
//  WeatherListView.swift
//  weather
//
//  Created by HingTatTsang on 11/12/2022.
//

import SwiftUI
import WeatherKit
import MapKit
import CoreLocation
import Contacts

struct WeatherListView: View {
    @State var place = ["", ""]
    @State var location = CLLocation(latitude: 22.302711, longitude: 114.177216)
    @ObservedObject var weatherKitManager = WeatherKitManager()
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(place[0])
                        .font(.title)
                        .foregroundColor(.white)
                    Spacer()
                }
                HStack {
                    Text(place[1])
                        .font(.title3)
                        .foregroundColor(.white)
                    Spacer()
                }
            }
            Spacer()
            VStack {
                Text(Image(systemName: weatherKitManager.symbol))
                    .font(.title)
                    .foregroundColor(.white)
                Text(weatherKitManager.temp)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
                .task {
                    await weatherKitManager.getWeather(input: location)
                }
                .onAppear() {
                    getReverSerGeoLocation(location: location)
                }
            
        }
        
        .padding()
        .background(Color.black)
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
struct WeatherListView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherListView()
    }
}
