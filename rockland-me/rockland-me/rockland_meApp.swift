//
//  rockland_meApp.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/13/23.
//

import SwiftUI
import MacUI
import ViewModels

@main
struct rockland_meApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            POITable().environmentObject(PointOfInterestViewModel())
            #else
            AppEntryView()
            #endif
        }
    }
}
