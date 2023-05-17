//
//  FestivalsViewModel.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/17/23.
//

import SwiftUI

class FestivalsViewModel: ObservableObject {
    @Published var festivals: [Festival] = []

    var festivalsFilteredBySearch: [Festival] {
        festivals.containing(searchTerm: searchInput)
    }

    @Published var urlSessionError: Error? = nil
    @Published var jsonDecodeError: Error? = nil
    private let endpoint: Endpoint

    @Published var searchInput: String = ""

    init(endpoint: Endpoint = .festivals) {
        self.endpoint = endpoint
    }

    func load() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: endpoint.url())
            do {
                festivals = try JSONDecoder().decode([Festival].self, from: data)
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
