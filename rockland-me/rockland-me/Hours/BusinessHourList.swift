//
//  BusinessHourList.swift
//  rockland-me
//
//  Created by Matt Bonney on 6/14/23.
//

import SwiftUI
import ViewModels

struct BusinessHourList: View {
    @AppStorage("WeekStartsOnMonday") var weekStartsOnMonday: Bool = false
    let hours: PointOfInterest.Hours

    var body: some View {
        if weekStartsOnMonday == false {
            LabeledContent("Sunday") {
                label(for: hours.sun)
            }
        }

        LabeledContent("Monday") {
            label(for: hours.mon)
        }

        LabeledContent("Tuesday") {
            label(for: hours.tue)
        }
        LabeledContent("Wednesday") {
            label(for: hours.wed)
        }

        LabeledContent("Thursday") {
            label(for: hours.thr)
        }

        LabeledContent("Friday") {
            label(for: hours.fri)
        }

        LabeledContent("Saturday") {
            label(for: hours.sat)
        }

        if weekStartsOnMonday == true {
            LabeledContent("Sunday") {
                label(for: hours.sun)
            }
        }
    }

    @ViewBuilder func label(for hours: [String]) -> some View {
        if hours.isEmpty {
            Text("Closed")
        } else {
           Text(hours.joined(separator: "\n"))
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
        }
    }
}

struct BusinessHourList_Previews: PreviewProvider {
    static let json = """
{
    "mon": ["11 am - 2:30 pm", "4 pm - 7:30 pm"],
    "tue": [],
    "wed": [],
    "thr": ["11 am - 2:30 pm", "4 pm - 7:30 pm"],
    "fri": ["11 am - 2:30 pm", "4 pm - 7:30 pm"],
    "sat": ["11 am - 2:30 pm", "4 pm - 7:30 pm"],
    "sun": ["11 am - 2:30 pm", "4 pm - 7 pm"]
}
"""

    static var previews: some View {
        if let data = json.data(using: .utf8),
           let hours = try? JSONDecoder().decode(PointOfInterest.Hours.self, from: data) {
            List {
                BusinessHourList(hours: hours)
            }
        } else {
            Text("Error.")
        }
    }
}
