//
//  POIDetailView.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/16/23.
//

import SwiftUI
import MBUtilities
import MapKit
import ViewModels

struct POIDetailView: View {
    let poi: PointOfInterest
    @State private var poiCoordinate: CLLocationCoordinate2D? = nil

    init(poi: PointOfInterest) {
        self.poi = poi
    }

    var body: some View {
        List {
            Section {
                Text(poi.name)
                    .font(.title)
                    .fontWeight(.bold)

                if poi.tags.isEmpty == false {
                    HStack {
                        ForEach(poi.tags) { tag in
                            tag.button(action: {})
                        }
                    }
                }

                if poi.description.isEmpty == false {
                    Text(poi.description)
                        .foregroundStyle(.secondary)
                }
            }
            .listRowSeparator(.hidden)

            if let poiCoordinate {
                Map(coordinateRegion: .constant(MKCoordinateRegion(center: poiCoordinate, span: .delta(0.003))), interactionModes: .zoom)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .listRowSeparator(.hidden, edges: .bottom)
            }


            Section {
                Button { } label: {
                    Label(poi.address, systemImage: "map.fill")
                }
                Button {
                    //
                } label: {
                    Label(poi.phone, systemImage: "phone.fill")
                }
                Button { } label: {
                    Label(poi.url, systemImage: "safari")
                }
            }

            Section("Business Hours") {
                BusinessHourList(hours: poi.hours)
            }
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {

                }) {
                    Label("Add to Favorites", systemImage: "heart")
                }
            }
        }
        .task {
            // Try to load the coordinate for a map preview
            poiCoordinate = await poi.getCoordinate()
        }
    }

    func hoursSection(hours: PointOfInterest.Hours) -> some View {
        Section("Hours") {
            ForEach(hours.asArray(), id: \.self.Day) { day in
                LabeledContent(day.Day) {
                    Text(day.BusinessHours)
                }
            }
        }
    }
}

struct POIDetailView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            POIDetailView(poi: PointOfInterest.preview)
        }
    }
}
