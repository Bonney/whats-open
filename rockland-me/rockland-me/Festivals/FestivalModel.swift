//
//  FestivalModel.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/17/23.
//

import Swift
import SwiftUI

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

struct Festival: Codable, Identifiable, Hashable {
    typealias Tag = String
    
    let id: Int
    let name: String
    let description: String
    let notes: String
    let emoji: String
    let address: String
    let phone: String
    let webUrl: String
    let tags: [Festival.Tag]
    var dates: [Date]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.notes = try container.decode(String.self, forKey: .notes)
        self.emoji = try container.decode(String.self, forKey: .emoji)
        self.address = try container.decode(String.self, forKey: .address)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.webUrl = try container.decode(String.self, forKey: .webUrl)
        self.tags = try container.decode([Festival.Tag].self, forKey: .tags)
//        self.dates = try container.decode([Date].self, forKey: .dates)

        let dateStrings = try container.decode([String].self, forKey: .dates)
        let formatter = DateFormatter.yyyyMMdd

        let convertedDates: [Date] = dateStrings.compactMap { dateString in
            formatter.date(from: dateString)
        }

        self.dates = convertedDates

//        func convertDates(_ dateStrings: [String]) -> [Date] {
//            guard dateStrings.isEmpty == false else {
//                return []
//            }
//
//            return dateStrings.compactMap {
//                unwrapDate($0)
//            }
//        }
//
//        self.dates = convertDates(dateStrings)

//        self.dates = try container.decode([Date].self, forKey: .dates)
    }
}

extension Festival {
    private func unwrapDate(_ stringRepresentation: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: stringRepresentation)
    }
}

extension Array<Festival> {
    func containing(searchTerm: String) -> Self {
        guard searchTerm.isEmpty == false else {
            return self
        }
        
        return self.filter { poi in
            poi.name.localizedCaseInsensitiveContains(searchTerm)
            || poi.description.localizedCaseInsensitiveContains(searchTerm)
        }
    }
}

// MARK: SwiftUI
extension Festival {
    @ViewBuilder func listCell() -> some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
    }
}

// MARK: Previews
extension Festival {
    static let preview: Festival = {
        let jsonString = """
[{
        "id": 1,
        "name": "Maine Lobster Festival",
        "description": "The Maine Lobster Festival is five days of fun and feasting on the fabulous coast of Maine! What started as an idea for a local marine festival to revive Midcoast Maine communities has turned into an internationally-recognized celebration of local seafood. The Maine Lobster Festival attracts visitors from as near as our local communities to those from countries around the globe.",
        "notes": "",
        "emoji": "🦞",
        "address": "Rockland Harbor Park, 1 Pleasant St, Rockland ME 04841",
        "phone": "207-596-7126",
        "webUrl": "https://mainelobsterfestival.com/",
        "tags": [
            "seafood", "festival"
        ],
        "dates": [
            "2023-08-02", "2023-08-03", "2023-08-04", "2023-08-05", "2023-08-06"
        ]
    }]
"""
        return try! JSONDecoder().decode([Festival].self, from: jsonString.data(using: .utf8)!).first!
    }()
}
