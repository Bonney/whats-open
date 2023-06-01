//
//  POIListView.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/17/23.
//

import SwiftUI
import MapKit
import ViewModels

struct POIListView: View {
    @EnvironmentObject private var viewModel: PointOfInterestViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HorizontalTagPicker(tags: viewModel.pointsOfInterest.allUniqueTags()) { tag in
                        viewModel.toggleSearchToken(for: tag)
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.top, -12)
                }
                .listSectionSeparator(.hidden, edges: .top)


                Section {
                    ForEach(viewModel.pointsOfInterestFilteredBySearch) { poi in
                        NavigationLink(value: poi) {
                            LabeledContent {
                            } label: {
                                poi.listCell()
                            }
                        }
                    }
                }
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .searchable(text: $viewModel.searchInput, tokens: $viewModel.searchTokens, prompt: Text("Search by Name, Cuisine, and more"), token: { (poiTag: PointOfInterest.Tag) in
                Text(poiTag.labelWithEmojiAnnotation())
            })
            .listStyle(.plain)
            .navigationTitle("Restaurants")
            .navigationDestination(for: PointOfInterest.self) { poi in
                POIDetailView(poi: poi)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

struct POIListView_Previews: PreviewProvider {
    static var previews: some View {
        POIListView()
            .environmentObject(PointOfInterestViewModel(endpoint: .pointsOfInterest))
    }
}
