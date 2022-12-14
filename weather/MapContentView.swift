//
//  MapContentView.swift
//  weather
//
//  Created by HingTatTsang on 11/12/2022.
//

import SwiftUI
import WeatherKit
import MapKit
import CoreLocation
import Contacts

struct MapContentView: View {
    @State var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 22.302711,
                longitude: 114.177216
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 10,
                longitudeDelta: 114.177216
            )
        )
    @State var regiontemp = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 22.302711,
                longitude: 114.177216
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 10,
                longitudeDelta: 114.177216
            )
        )
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region)
            
        }
        .ignoresSafeArea()
        .onChange(of: region.center.longitude) { _ in
            region = regiontemp
        }
        .onAppear() {
            regiontemp = region
        }
    }
}
struct MapContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapContentView()
    }
}
