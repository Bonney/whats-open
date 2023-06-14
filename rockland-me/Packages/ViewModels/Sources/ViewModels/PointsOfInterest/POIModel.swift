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
//        "id": "1111",
//        "name": "Bob's Burgers",
//        "description": "A family-owned burger place.",
//        "address": "123 Main St, Rockland ME 04841",
//        "phone": "207-123-4567",
//        "url": "www.bobsburgers.com/",
//        "tags": [
//            "pub", "burgers", "beer"
//        ],
//        "hours": {
//            "mon": ["9 am - 5 pm"],
//            "tue": ["11 am - 12 pm", "3 pm - 5pm],
//            "wed": ["11 am - 8:30 pm"],
//            "thr": ["11 am - 8:30 pm"],
//            "fri": ["11 am - 9 pm"],
//            "sat": ["11 am - 9 pm"],
//            "sun": ["closed"]
//        }
//    },

public struct PointOfInterest: Codable, Identifiable, Hashable {
    public typealias Tag = String

    public struct Hours: Codable, Hashable {
        public let mon: [String]
        public let tue: [String]
        public let wed: [String]
        public let thr: [String]
        public let fri: [String]
        public let sat: [String]
        public let sun: [String]

        public var today: [String] {
            switch Calendar.current.component(.weekday, from: Date.now) {
                case 1:
                    return mon
                case 2:
                    return tue
                case 3:
                    return wed
                case 4:
                    return thr
                case 5:
                    return fri
                case 6:
                    return sat
                default:
                    return sun
            }
        }

        public func asArray() -> [(Day: String, BusinessHours: String)] {
            [
                ("Monday", mon.joined(separator: ", ")),
                ("Tuesday", tue.joined(separator: ", ")),
                ("Wednesday", wed.joined(separator: ", ")),
                ("Thursday", thr.joined(separator: ", ")),
                ("Friday", fri.joined(separator: ", ")),
                ("Saturday", sat.joined(separator: ", ")),
                ("Sunday", sun.joined(separator: ", "))
            ]
        }
    }

    public let id: String
    public let name: String
    public let description: String
    public let address: String
    public let phone: String
    public let url: String
    public let tags: [PointOfInterest.Tag]
    public let hours: PointOfInterest.Hours
}

//public extension PointOfInterest {
//    func willBeOpenToday() -> Bool {
//        let currentWeekday = Calendar.current.component(.weekday, from: Date())
//        // @TODO: Logic for determining if business is open.
//        switch currentWeekday {
//            case 1:
//                return hours.mon.contains("closed") == false
//            case 2:
//                return hours.tue.contains("closed") == false
//            case 3:
//                return hours.wed.contains("closed") == false
//            case 4:
//                return hours.thr.contains("closed") == false
//            case 5:
//                return hours.fri.contains("closed") == false
//            case 6:
//                return hours.sat.contains("closed") == false
//            default:
//                return hours.sun.contains("closed") == false
//        }
//    }
//}

public extension Array<PointOfInterest> {
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
public extension PointOfInterest {
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
public extension PointOfInterest {
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

public extension Array<PointOfInterest.Tag> {
    func containing(searchTerm: String) -> Self {
        self.filter { tag in
            tag.localizedCaseInsensitiveContains(searchTerm)
        }
    }
}

extension PointOfInterest.Tag: Identifiable {
    public var id: String { self }
}

public extension PointOfInterest.Tag {
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

public extension PointOfInterest.Tag {
    @ViewBuilder func button(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(self.labelWithEmojiAnnotation())
                .fontWeight(.medium)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle)
        .controlSize(.small)
    }
}

public extension PointOfInterest {
    static let preview: PointOfInterest = {
        let jsonString = """
[{
        "id": "eclipse-of-the-pearl-rockland",
        "name": "Eclipse of the Pearl",
        "description": "",
        "address": "273 Main St, Rockland ME 04841",
        "phone": "207-593-8847",
        "url": "https://www.facebook.com/eclipseofthepearl",
        "tags": [
            "seafood"
        ],
        "hours": {
            "mon": ["11 am - 2:30 pm", "4 pm - 7:30 pm"],
            "tue": [],
            "wed": [],
            "thr": ["11 am - 2:30 pm", "4 pm - 7:30 pm"],
            "fri": ["11 am - 2:30 pm", "4 pm - 7:30 pm"],
            "sat": ["11 am - 2:30 pm", "4 pm - 7:30 pm"],
            "sun": ["11 am - 2:30 pm", "4 pm - 7 pm"]
        }
    }]
"""
        return try! JSONDecoder().decode([PointOfInterest].self, from: jsonString.data(using: .utf8)!).first!
    }()
}
