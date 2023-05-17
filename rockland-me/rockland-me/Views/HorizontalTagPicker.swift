//
//  HorizontalTagPicker.swift
//  rockland-me
//
//  Created by Matt Bonney on 5/16/23.
//

import SwiftUI

struct HorizontalTagPicker: View {
    let tags: [PointOfInterest.Tag]
    let onSelect: (PointOfInterest.Tag) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Button {
                        onSelect(tag)
                    } label: {
                        Text(tag.labelWithEmojiAnnotation())
                            .fontWeight(.medium)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
                }
            }
            .padding()
        }
    }
}

struct HorizontalTagPicker_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalTagPicker(tags: ["seafood", "pizza", "delivery", "bbq", "italian", "breakfast", "wine", "mexican", "coffee", "pub", "thai", "sushi"]) { tag in
            print("Selected \(tag.labelWithEmojiAnnotation())")
        }
    }
}
