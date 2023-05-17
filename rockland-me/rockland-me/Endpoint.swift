//
//  Endpoint.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/16/23.
//

import Foundation

public enum Endpoint: String {
    case pointsOfInterest = "https://bonney.github.io/rockland-me/data.json"
    case festivals = "https://bonney.github.io/rockland-me/festivals.json"

    public func url() -> URL {
        guard let url = URL(string: self.rawValue) else {
            fatalError("Given Endpoint URL does not resolve.")
        }
        return url
    }
}
