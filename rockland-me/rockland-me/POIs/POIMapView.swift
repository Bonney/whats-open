//
//  POIMapView.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/17/23.
//

import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    static let centeredOverRocklandThomastonME = CLLocationCoordinate2D(latitude: 44.103, longitude: -69.108)
}

extension MKCoordinateSpan {
    static let defaultZoomLevel = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    static let detailedZoomLevel = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
}

struct POIMapView: View {
    @EnvironmentObject private var viewModel: PointOfInterestViewModel
    @State private var navigationPath: [PointOfInterest] = []

    @State private var mapCoordinateRegion = MKCoordinateRegion(center: .centeredOverRocklandThomastonME, span: .defaultZoomLevel)

    struct Annotation: Identifiable {
        var id: UUID
        var coordinate: CLLocationCoordinate2D
        init(id: UUID = UUID(), _ coordinate: CLLocationCoordinate2D) {
            self.id = id
            self.coordinate = coordinate
        }
    }

    @State private var annotations: [Annotation] = []

    func currentNavPathCoordinate() async -> MKCoordinateRegion {
        if let last = navigationPath.last, let coordinate = await last.getCoordinate() {
            return MKCoordinateRegion(center: coordinate, span: .detailedZoomLevel)
        }
        return MKCoordinateRegion(center: .centeredOverRocklandThomastonME, span: .defaultZoomLevel)
    }

    @ViewBuilder func map() -> some View {
        Map(coordinateRegion: $mapCoordinateRegion, annotationItems: annotations, annotationContent: { annotation in
            MapMarker(coordinate: annotation.coordinate)
        })
        .ignoresSafeArea()
    }

    @ViewBuilder func list() -> some View {
        NavigationStack(path: $navigationPath) {
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
            .searchable(text: $viewModel.searchInput, prompt: Text("Search by Name, Cuisine, and more"))
            .listStyle(.plain)
            .navigationTitle("Restaurants")
            .navigationDestination(for: PointOfInterest.self) { poi in
                POIDetailView(poi: poi)
            }
        }
    }

    var body: some View {
        GeometryReader { g in
            map()
                .frame(maxHeight: g.size.height * 0.7, alignment: .top)
        }
            .sheet(isPresented: .constant(true)) {
                list()
                    .presentationDetents([.fraction(0.5), .fraction(0.99)])
                    .presentationContentInteraction(.scrolls)
                    .presentationBackgroundInteraction(.enabled)
                    .interactiveDismissDisabled()
            }
        .task {
            await viewModel.load()

//            for poi in viewModel.pointsOfInterest {
//                if let coord = await poi.getCoordinate() {
//                    annotations.append(Annotation(coord))
//                }
//            }
        }
        .onChange(of: navigationPath) { newPath in
            Task { @MainActor in
                let new = await currentNavPathCoordinate()

                var nextAnnotation: [Annotation] = []

                if let coord = await navigationPath.last?.getCoordinate() {
                    nextAnnotation = [Annotation(coord)]
                }

                withAnimation(.easeOut) {
                    mapCoordinateRegion = new
                    annotations = nextAnnotation
                }

            }
        }
    }
}

struct POIMapView_Previews: PreviewProvider {
    static var previews: some View {
        POIMapView()
            .environmentObject(PointOfInterestViewModel())
    }
}
