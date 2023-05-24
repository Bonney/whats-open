//
//  FestivalDetailView.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/23/23.
//

import SwiftUI
import MBUtilities

struct FestivalDetailView: View {
    let festival: Festival

    var body: some View {
        List {
            Text(festival.name)

            Section("Dates") {
                ForEach(festival.dates, id: \.timeIntervalSince1970) { date in
                    Text(date, format: .dateTime.day().month(.wide).year())
                }
            }
        }
    }


}

struct FestivalDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FestivalDetailView(festival: Festival.preview)
    }
}
