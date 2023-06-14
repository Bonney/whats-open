//
//  FestivalListView.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/17/23.
//

import SwiftUI

struct FestivalListView: View {
    @EnvironmentObject private var viewModel: FestivalsViewModel


    func header(for dates: [Date]) -> String {
        // Extract start and end dates.
        guard let start = dates.sorted().first,
              let end = dates.sorted().last else {
            return "No Dates"
        }

        return [start, end].map { date in
            date.formatted(date: .abbreviated, time: .omitted)
        }
        .joined(separator: " to ")
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.festivalsFilteredBySearch.sorted {
                    ($0.dates.first ?? Date.now) < ($1.dates.first ?? Date.now)
                }) { festival in
                    Section {
                        NavigationLink(value: festival) {
                            HStack {
                                Text(festival.emoji)
                                    .font(.system(size: 40))
                                festival.listCell()
                            }
                        }
                    } header: {
                        Text(header(for: festival.dates))
                    }
                }
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .searchable(text: $viewModel.searchInput, prompt: Text("Search Local Events"))
            .listStyle(.plain)
            .navigationTitle("Festivals & Events")
            .navigationDestination(for: Festival.self) { festival in
                FestivalDetailView(festival: festival)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

struct FestivalView_Previews: PreviewProvider {
    static var previews: some View {
        FestivalListView()
            .environmentObject(FestivalsViewModel())
    }
}

