//
//  ContentView.swift
//  weather
//
//  Created by HingTatTsang on 10/12/2022.
//

import SwiftUI
import WeatherKit
import MapKit
import CoreLocation
import Contacts
import MapItemPicker
import Foundation

struct ContentView: View {
    @State var isOnline = true
    @State var refresh = false
    @ObservedObject var weatherKitManager = WeatherKitManager()
    @State var showingPicker = false
    @State var place: Array<CLLocation> = []
    @State var allplacestring = ""
    @State var showedit = false
    var body: some View {
        NavigationView {
            ScrollView {
                Button(action: {
                    showingPicker = true
                }, label: {
                    VStack {
                        HStack {
                            VStack {
                                HStack {
                                    Spacer()
                                    Label("新增地點", systemImage: "plus")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                            .padding()
                            
                        }
                        .background(Color.blue)
                        .cornerRadius(20)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                })
                if refresh {
                    refreshhelper(refresh: $refresh)
                } else {
                    if isOnline {
                        ForEach((place), id: \.self) { i in
                            VStack {
                                NavigationLink(destination: WeatherContentView(location: i), label: {
                                    WeatherListView(location: i)
                                        .cornerRadius(20)
                                        .contextMenu {
                                            Button(action: {
                                                place.remove(at: place.firstIndex(of: i)!)
                                                save()
                                                update()
                                            }, label: {
                                                Label("刪除", systemImage: "delete.backward")
                                            })
                                            .foregroundColor(.red)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 2)
                                    
                                })
                                
                            }
                            
                            
                        }
                    } else {
                        VStack {
                            Text("請檢查網絡連線")
                                .font(.largeTitle)
                            ProgressView()
                        }
                    }
                    
                    
                }
                appleView()
            }
            .mapItemPicker(isPresented: $showingPicker) { item in
                let l1 = item?.placemark.location?.coordinate.latitude
                let l2 = item?.placemark.location?.coordinate.longitude
                if l1 != nil || l2 != nil {
                    place.append(CLLocation(latitude: l1!, longitude: l2!))
                    save()
                    update()
                }
                
            }
            
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .bottom, endPoint: .top))
            .navigationTitle("天氣")
            .refreshable {
                update()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.white)
        .onAppear() {
            update()
        }
        .onChange(of: place) { _ in
            save()
        }
        
        
        
    }
    func save() -> Void {
        allplacestring = ""
        for i in place {
            let temp0 = i.coordinate.latitude
            let temp1 = i.coordinate.longitude
            let temp2 = ["\(temp0)", "\(temp1)"]
            let temp3 = temp2.joined(separator: "/con/")
            allplacestring = "\(allplacestring)/location/\(temp3)"
            getdata().savedefaultsdata(type: "location", data: allplacestring)
        }
    }
    func update() -> Void {
        place = []
        let a = getdata().getdefaultsdata(type: "location")
        let array1 = a.components(separatedBy: "/location/")
        for i in array1 {
            if i != "" {
                let array2 = i.components(separatedBy: "/con/")
                place.append(CLLocation(latitude: Double(array2[0])!, longitude: Double(array2[1])!))
            }
        }
        refresh = true
        
    }
}

// MARK: 重新整理
struct refreshhelper: View {
    let defaults = UserDefaults.standard
    @State var alldatakey = ["ismoved"]
    @State var alldatastring = ["ismoved"]
    @Binding var refresh: Bool
    var body: some View {
        Text("refresh helper")
            .font(.largeTitle)
            .foregroundColor(.white)
            .bold()
            .hidden()
        
            .onAppear() {
                refresh = false
            }
        
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


@MainActor class WeatherKitManager: ObservableObject {
    
    @Published var weather: Weather?
    
    
    func getWeather(input: CLLocation) async -> Void {
        do {
            weather = try await Task.detached(priority: .userInitiated) {
                return try await WeatherService.shared.weather(for: input)
            }.value
        } catch {
            
        }
    }
    
    var symbol: String {
        weather?.currentWeather.symbolName ?? "questionmark"
    }
    
    var temp: String {
        let temp =
        weather?.currentWeather.temperature
        
        let convert = temp?.formatted()
        
        return convert ?? "--"
        
    }
    
    
}

extension CLPlacemark {
    /// street name, eg. Infinite Loop
    var streetName: String? { thoroughfare }
    /// // eg. 1
    var streetNumber: String? { subThoroughfare }
    /// city, eg. Cupertino
    var city: String? { locality }
    /// neighborhood, common name, eg. Mission District
    var neighborhood: String? { subLocality }
    /// state, eg. CA
    var state: String? { administrativeArea }
    /// county, eg. Santa Clara
    var county: String? { subAdministrativeArea }
    /// zip code, eg. 95014
    var zipCode: String? { postalCode }
    /// postal address formatted
    @available(iOS 11.0, *)
    var postalAddressFormatted: String? {
        guard let postalAddress = postalAddress else { return nil }
        return CNPostalAddressFormatter().string(from: postalAddress)
    }
}

extension CLLocation {
    func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
    }
}

struct appleView: View {
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("數據來源: 天氣")
                        .foregroundColor(.white)
                        .font(.footnote)
                        .padding(.horizontal)
                    Link("法律資訊", destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!)
                        .foregroundColor(.white)
                        .font(.footnote)
                        .padding(.horizontal)
                }
            }
            .padding(5)
            VStack {
                HStack {
                    Link("Copyright © 2022 TsangHingTat", destination: URL(string: "http://alwaysboringstudio.github.io/ins.html")!)
                        .foregroundColor(.white)
                        .font(.footnote)
                        .padding(.horizontal)
                }
            }
            .padding(.horizontal)
        }
        .padding(5)
    }
}
