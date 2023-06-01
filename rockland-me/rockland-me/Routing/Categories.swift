//
//  Categories.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/31/23.
//

import Foundation
import SwiftUI

enum Category: String, Identifiable, CaseIterable {
    var id: String { self.rawValue }

    case restaurants
    case festivals
    case locations
    case favorites
}

extension Category {
    var title: String {
        switch self {
            case .restaurants:
                return "Food & Drink"
            case .festivals:
                return "Events"
            case .locations:
                return "Explore"
            case .favorites:
                return "Favorites"
        }
    }

    var systemImage: String {
        switch self {
            case .restaurants:
                return "fork.knife"
            case .festivals:
                return "ticket"
            case .locations:
                return "map"
            case .favorites:
                return "heart"
        }
    }
}

extension Category: View {
    // The main entry point for this given category's view hierarchy.
    var body: some View {
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

extension Category {
    // Returns a SwiftUI Label using the Category's `title` and `systemImage` computed properties.
    func tabItem() -> some View {
        switch self {
            case .restaurants:
                return Label(title, systemImage: systemImage)
            case .festivals:
                return Label(title, systemImage: systemImage)
            case .locations:
                return Label(title, systemImage: systemImage)
            case .favorites:
                return Label(title, systemImage: systemImage)
        }
    }
}
