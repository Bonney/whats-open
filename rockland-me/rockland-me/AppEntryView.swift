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
            POIListView(viewModel: poiViewModel)
                .tabItem {
                    Label("Restaurants", systemImage: "fork.knife")
                }

            FestivalListView(viewModel: festivalsViewModel)
                .tabItem {
                    Label("Festivals", systemImage: "ticket")
                }

            NavigationStack {
                List {
                    Text("Locations")
                }
                .navigationTitle("Locations")
            }
            .tabItem {
                Label("Locations", systemImage: "map")
            }

            // A favorites tab
            NavigationStack {
                List {
                    Text("Favorites")
                }
                .navigationTitle("Favorites")
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
            }

        }
        .listStyle(.plain)
    }
}

struct AppEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AppEntryView()
    }
}
