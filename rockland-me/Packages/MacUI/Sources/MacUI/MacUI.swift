import SwiftUI
import ViewModels
import MapKit
import Routing

public struct POITable: View {
    @EnvironmentObject private var poiViewModel: PointOfInterestViewModel

    @State private var searching = ""
    @State private var selection = Set<PointOfInterest.ID>()
    @State private var sortOrder = [KeyPathComparator(\PointOfInterest.name)]

    @AppStorage("ShowRightSidebar") var showRightSidebar: Bool = true

    private struct MapAnnotation: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }

    @State private var annotations: [MapAnnotation] = []

    private var columnVisibility: Binding<NavigationSplitViewVisibility> {
        Binding {
            if showRightSidebar {
                return .doubleColumn
            } else {
                return .detailOnly
            }
        } set: { newValue in
            switch newValue {
                case .all, .doubleColumn:
                    showRightSidebar = true
                case .detailOnly:
                    showRightSidebar = false
                default:
                    showRightSidebar = false
            }
        }
    }

    public init() {
    }

    public var body: some View {
        let _ = Self._printChanges()

        Group {
            if showRightSidebar {
                NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
                    EmptyView()
                } content: {
                    table
                } detail: {
                    map
                }
            } else {
                NavigationStack {
                    table
                }
            }
        }
//
//        NavigationSplitView() {
//            EmptyView()
//        } content: {
//            table
//        } detail: {
//            if showRightSidebar {
//                map
//            } else {
//                EmptyView()
//            }
//        }
//        VSplitView {
//            map
//                .frame(maxHeight: showRightSidebar ? 300 : 0)
//                .compositingGroup()
//                .animation(.linear, value: showRightSidebar)
//
//            table
//        }
        .toolbar {
            ToolbarItem {
                favoriteButton
            }
            ToolbarItem {
                Toggle(isOn: $showRightSidebar) {
                    Label(showRightSidebar ? "Hide Map" : "Show Map", systemImage: "map")
                }
                .toggleStyle(.button)
            }
        }
        .task {
            await poiViewModel.load()
        }
        .onChange(of: selection) { newSelection in
            withAnimation(.easeOut) {
                updateAnnotations(with: newSelection)
            }
        }
    }

    private func updateAnnotations(with selection: Set<PointOfInterest.ID>) {
        Task { @MainActor in
            var coordinates: [CLLocationCoordinate2D] = []
            let selected = poiViewModel.pointsOfInterest.filter { selection.contains($0.id) }
            for selection in selected {
                if let coordinate = await selection.getCoordinate() {
                    coordinates.append(coordinate)
                }
            }
            annotations = coordinates.map { MapAnnotation(coordinate: $0) }
        }
    }

    @ViewBuilder private var favoriteButton: some View {
        Button {
            //
        } label: {
            Label("Favorite", systemImage: "heart")
        }
    }

    private var mapRegion: Binding<MKCoordinateRegion> {
        Binding(get: {
            let region = MKCoordinateRegion(
                center: annotations.first?.coordinate ?? CLLocationCoordinate2D(latitude: 44.103, longitude: -69.108),
                span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
            )
            return region
        }, set: { _ in
        })
    }

    @ViewBuilder var map: some View {
        Map(coordinateRegion: mapRegion, annotationItems: annotations) { annotation in
            MapMarker(coordinate: annotation.coordinate)
        }
    }

    var sidebar: some View {
        List {
            ForEach(AppCategory.allCases) { category in
                category.tabItem()
            }

        }
    }

    var table: some View {
        Table(of: PointOfInterest.self,
              selection: $selection,
              sortOrder: $sortOrder
        ) {
            TableColumn("Restaurant", value: \.name) { tableItem in
                Text(tableItem.name)
            }

            TableColumn("Phone", value: \.phone) { tableItem in
                Text(tableItem.phone)
            }

//            TableColumn(
//                Date.now.formatted(Date.FormatStyle().weekday(.wide)) + " (Today)"
//            ) { tableItem in
//                Text(tableItem.hours.today)
//            }
        } rows: {
            ForEach(
                poiViewModel.pointsOfInterest
                    .sorted(using: sortOrder)
                    .filter {
                        searching.isEmpty || $0.name.localizedCaseInsensitiveContains(searching)
                    }
            ) { tableItem in
                TableRow(tableItem)
            }
        }
        .searchable(text: $searching)
        .navigationTitle("Restaurants")
//        .navigationSubtitle(String(describing: poiViewModel.pointsOfInterest.count) + " items")
    }
}

public struct POITable_Previews: PreviewProvider {
    public static var previews: some View {
        POITable()
            .environmentObject(PointOfInterestViewModel(endpoint: .pointsOfInterest))
    }
}
