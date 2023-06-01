//
//  AppEntryView.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/17/23.
//

import SwiftUI
import ViewModels
import Routing

extension AppCategory: View {
    // The main entry point for this given category's view hierarchy.
    public var body: some View {
        switch self {
            case .restaurants:
                POIListView()
            case .festivals:
                FestivalListView()
            case .locations:
                Text("Locations View")
            case .favorites:
                Text("Favorites View")
        }
    }
}

struct AppEntryView: View {
    @StateObject private var poiViewModel = PointOfInterestViewModel()
    @StateObject private var festivalsViewModel = FestivalsViewModel()

    var body: some View {
        TabView {
            ForEach(AppCategory.allCases) { category in
                category.body
                    .tabItem(category.tabItem)
            }
        }
        .listStyle(.plain)
        .environmentObject(poiViewModel)
        .environmentObject(festivalsViewModel)
    }
}

struct AppEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AppEntryView()
    }
}
