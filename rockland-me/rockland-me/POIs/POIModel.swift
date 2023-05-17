//
//  PointOfInterest.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/16/23.
//

import SwiftUI
import MapKit

// Example of JSON data from server:
//    {
//        "id": 0,
//        "name": String,
//        "description": String,
//        "address": String,
//        "phone": String,
//        "url": String,
//        "tags": [
//            String
//        ],
//        "hours": {
//            "mon": "XX am - YY pm",
//            "tue": "11 am - 8:30 pm",
//            "wed": "11 am - 8:30 pm",
//            "thr": "11 am - 8:30 pm",
//            "fri": "11 am - 9 pm",
//            "sat": "11 am - 9 pm",
//            "sun": "closed"
//        }
//    },

struct PointOfInterest: Codable, Identifiable, Hashable {
    typealias Tag = String

    struct Hours: Codable, Hashable {
        let mon: String
        let tue: String
        let wed: String
        let thr: String
        let fri: String
        let sat: String
        let sun: String

        func asArray() -> [(Day: String, BusinessHours: String)] {
            [
                ("Monday", mon),
                ("Tuesday", tue),
                ("Wednesday", wed),
                ("Thursday", thr),
                ("Friday", fri),
                ("Saturday", sat),
                ("Sunday", sun)
            ]
        }
    }

    let id: Int
    let name: String
    let description: String
    let address: String
    let phone: String
    let url: String
    let tags: [PointOfInterest.Tag]
    let hours: PointOfInterest.Hours
}

extension PointOfInterest {

    func willBeOpenToday() -> Bool {
        let currentWeekday = Calendar.current.component(.weekday, from: Date())
        // @TODO: Logic for determining if business is open.
        return Bool.random()
    }
}

extension Array<PointOfInterest> {
    func containing(searchTerm: String) -> Self {
        guard searchTerm.isEmpty == false else {
            return self
        }

        return self.filter { poi in
            poi.name.localizedCaseInsensitiveContains(searchTerm)
            || poi.description.localizedCaseInsensitiveContains(searchTerm)
            || poi.tags.containing(searchTerm: searchTerm).isEmpty == false
            || poi.address.localizedCaseInsensitiveContains(searchTerm)
            || poi.phone.localizedCaseInsensitiveContains(searchTerm)
        }
    }

    func allUniqueTags() -> [PointOfInterest.Tag] {
        var output = [PointOfInterest.Tag]()

        self.forEach { poi in
            poi.tags.forEach { tag in
                if output.contains(tag) == false {
                    output.append(tag)
                }
            }
        }

        return output
    }
}

// MARK: MapKit
extension PointOfInterest {
    var coordinate: CLLocationCoordinate2D? {
        let geocoder = CLGeocoder()
        var output: CLLocationCoordinate2D? = nil

        geocoder.geocodeAddressString(address) { places, error in
            if let error {
                print(error)
                return
            }

            guard let places, let first = places.first else {
                print("no places found")
                return
            }

            guard let location = first.location else {
                print("no location found")
                return
            }

            output = location.coordinate
        }

        return output
    }

    /// Assuming the address is a valid address, try to convert to a coordinate.
    func getCoordinate() async -> CLLocationCoordinate2D? {
        let geocorder = CLGeocoder()
        do {
            let placemarks = try await geocorder.geocodeAddressString(address)

            print("Loaded placemarks: \(placemarks)")

            guard let location = placemarks.first?.location else {
                print("no location found for placemark")
                return nil
            }

            return location.coordinate
        } catch {
            print(error)
            return nil
        }
    }
}

// MARK: SwiftUI
extension PointOfInterest {
    @ViewBuilder func listCell() -> some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(address)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder func phoneMenu() -> some View {
        Menu {
            Section {
                Button { } label: {
                    Label(phone, systemImage: "phone.fill")
                }
                Button { } label: {
                    Label("Directions", systemImage: "car.fill")
                }
            } header: {
                Text(name)
            }
        } label: {
            Image(systemName: "phone.fill")
        }
    }
}

extension Array<PointOfInterest.Tag> {
    func containing(searchTerm: String) -> Self {
        self.filter { tag in
            tag.localizedCaseInsensitiveContains(searchTerm)
        }
    }
}

extension PointOfInterest.Tag {
    func labelWithEmojiAnnotation() -> String {
        switch self {
            case "seafood":
                return "🦞 Seafood"
            case "pizza":
                return "🍕 Pizza"
            case "delivery":
                return "🚚 Delivery"
            case "bbq":
                return "🍖 BBQ"
            case "italian":
                return "🍝 Italian"
            case "breakfast":
                return "🍳 Breakfast"
            case "wine":
                return "🍷 Wine"
            case "beer":
                return "🍺 Beer"
            case "mexican":
                return "🌮 Mexican"
            case "coffee":
                return "☕️ Coffee"
            case "pub":
                return "🥩 Bar & Grill"
            case "thai":
                return "🍜 Thai"
            case "sushi":
                return "🍣 Sushi"
            default:
                return self.capitalized
        }
    }
}

extension PointOfInterest {
    static let preview: PointOfInterest = {
        let jsonString = """
[{
        "id": 0,
        "name": "Archers on the Pier",
        "description": "Seafood-centric cafe with a waterfront deck providing comfort eats & a robust beer & wine list.",
        "address": "58 Ocean St, Rockland ME 04841",
        "phone": "207-594-2435",
        "url": "https://archersonthepier.com/",
        "tags": [
            "seafood"
        ],
        "hours": {
            "mon": "11 am - 8:30 pm",
            "tue": "11 am - 8:30 pm",
            "wed": "11 am - 8:30 pm",
            "thr": "11 am - 8:30 pm",
            "fri": "11 am - 9 pm",
            "sat": "11 am - 9 pm",
            "sun": "closed"
        }
}]
"""
        return try! JSONDecoder().decode([PointOfInterest].self, from: jsonString.data(using: .utf8)!).first!
    }()
}
