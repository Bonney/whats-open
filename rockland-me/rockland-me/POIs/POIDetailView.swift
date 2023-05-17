//
//  POIDetailView.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/16/23.
//

import SwiftUI
import MBUtilities

struct POIDetailView: View {
    let poi: PointOfInterest

    var body: some View {
        List {
            Text(poi.name)
                .font(.title)
                .fontWeight(.bold)
                .listRowSeparator(.hidden, edges: .bottom)

            Text(poi.address)
                .listRowSeparator(.hidden, edges: .bottom)

            if poi.description.isEmpty == false {
                Text(poi.description)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button {
                    //
                } label: {
                    Label(poi.phone, systemImage: "phone.fill")
                }
                Button { } label: {
                    Label("Open in Maps", systemImage: "map.fill")
                }
                Button { } label: {
                    Label("Visit Website", systemImage: "safari")
                }
            }

            hoursSection(hours: poi.hours)
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(systemImage: "star") {
                    // TODO
                }
            }
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
