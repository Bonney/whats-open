//
//  FestivalModel.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/17/23.
//

import Swift
import SwiftUI

struct Festival: Codable, Identifiable, Hashable {
    typealias Tag = String

    let id: Int
    let name: String
    let description: String
    let notes: String
    let address: String
    let phone: String
    let webUrl: String
    let tags: [Festival.Tag]
    let startDate: String
    let endDate: String
    let dates: [String]
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
        }
    }
}
