//
//  PointOfInterestViewModel.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/17/23.
//

import SwiftUI

class PointOfInterestViewModel: ObservableObject {
    @Published var selection: PointOfInterest? = nil
    @Published var pointsOfInterest: [PointOfInterest] = []

    var pointsOfInterestFilteredBySearch: [PointOfInterest] {
        pointsOfInterest.containing(searchTerm: searchInput)
    }

    @Published var urlSessionError: Error? = nil
    @Published var jsonDecodeError: Error? = nil
    private let endpoint: Endpoint

    @Published var searchInput: String = ""
    func toggleSearchToken(for tag: PointOfInterest.Tag) {
        if searchInput.localizedCaseInsensitiveContains(tag) {
            searchInput = searchInput.replacingOccurrences(of: tag, with: "")
        } else {
            searchInput.append(tag)
        }
    }

    init(endpoint: Endpoint = .pointsOfInterest) {
        self.endpoint = endpoint
    }

    func load() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: endpoint.url())
            do {
                pointsOfInterest = try JSONDecoder().decode([PointOfInterest].self, from: data)
            } catch {
                print(error.localizedDescription)
                self.jsonDecodeError = error
            }
        } catch {
            print(error.localizedDescription)
            self.urlSessionError = error
        }
    }
}
