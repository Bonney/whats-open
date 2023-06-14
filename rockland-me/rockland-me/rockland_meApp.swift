//
//  rockland_meApp.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/13/23.
//

import SwiftUI
import ViewModels
#if os(macOS)
import MacUI
#endif

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
