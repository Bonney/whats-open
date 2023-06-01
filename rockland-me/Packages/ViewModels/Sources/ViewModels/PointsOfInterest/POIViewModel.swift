//
//  PointOfInterestViewModel.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/17/23.
//

import SwiftUI

@MainActor
public class PointOfInterestViewModel: ObservableObject {
    @Published public var selection: PointOfInterest? = nil
    @Published public var pointsOfInterest: [PointOfInterest] = []

    public var pointsOfInterestFilteredBySearch: [PointOfInterest] {
        pointsOfInterest.containing(searchTerm: searchInput + searchTokens.joined(separator: " "))
    }

    @Published public var urlSessionError: Error? = nil
    @Published public var jsonDecodeError: Error? = nil
    private let endpoint: JSONEndpoint

    @Published public var searchTokens: [PointOfInterest.Tag] = []
    @Published public var searchInput: String = ""

    public func toggleSearchToken(for tag: PointOfInterest.Tag) {
        if searchTokens.contains(tag) {
            searchTokens.removeAll(where: { $0 == tag })
        } else {
            searchTokens.append(tag)
        }
//        if searchInput.localizedCaseInsensitiveContains(tag) {
//            searchInput = searchInput.replacingOccurrences(of: tag, with: "")
//        } else {
//            searchInput.append(tag)
//        }
    }

    public init(endpoint: JSONEndpoint = .pointsOfInterest) {
        self.endpoint = endpoint
    }

    public func load() async {
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
