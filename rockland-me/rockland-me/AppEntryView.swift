//
//  AppEntryView.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/17/23.
//

import SwiftUI

struct AppEntryView: View {
    @StateObject private var poiViewModel = PointOfInterestViewModel()
    @StateObject private var festivalsViewModel = FestivalsViewModel()

    var body: some View {
        TabView {
            POIMapView()
                .environmentObject(poiViewModel)
                .tabItem {
                    Label("Restaurants", systemImage: "fork.knife")
                }

            FestivalListView(viewModel: festivalsViewModel)
                .tabItem {
                    Label("Festivals", systemImage: "ticket")
                }

            POIMapView().environmentObject(poiViewModel)
                .tabItem {
                    Label("Attractions", systemImage: "map")
                }
        }
    }
}

struct AppEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AppEntryView()
    }
}
