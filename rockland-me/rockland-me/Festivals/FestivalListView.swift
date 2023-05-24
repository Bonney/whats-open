//
//  FestivalListView.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/17/23.
//

import SwiftUI

struct FestivalListView: View {
    @ObservedObject private var viewModel: FestivalsViewModel

    init(viewModel: FestivalsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(viewModel.festivalsFilteredBySearch) { festival in
                        NavigationLink(value: festival) {
                            LabeledContent {
                            } label: {
                                festival.listCell()
                            }
                        }
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
        FestivalListView(viewModel: FestivalsViewModel())
    }
}

