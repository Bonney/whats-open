//
//  ContentView.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/13/23.
//

import SwiftUI
import MapKit

struct AnnotatedMap: View {
    @Binding var selection: PointOfInterest?
    let pointsOfInterest: [PointOfInterest]
    var annotations: [POIAnnotation] = []
    
    struct POIAnnotation: Identifiable {
        var id = UUID()
        let coordinate: CLLocationCoordinate2D
        
        init(_ coordinate: CLLocationCoordinate2D) {
            self.id = UUID()
            self.coordinate = coordinate
        }
    }
    
    @State private var mapCenter = CLLocationCoordinate2D(latitude: 44.103, longitude: -69.108)
    @State private var mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
    private var coordinateRegionBinding: Binding<MKCoordinateRegion> {
        Binding(
            get: {
                MKCoordinateRegion(center: mapCenter, span: mapSpan)
            },
            set: {
                print($0)
                //                mapCenter = $0.center
                //                mapSpan = $0.span
            }
        )
    }
    
    var body: some View {
        Map(coordinateRegion: coordinateRegionBinding, annotationItems: annotations) { annotation in
            MapMarker(coordinate: annotation.coordinate)
        }
        .overlay {
            Text(annotations.count, format: .number)
        }
    }
}
