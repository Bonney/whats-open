import SwiftUI

struct TableItem: Identifiable {
    let id: UUID = UUID()
    let title: String
    let description: String
    let timestamp: Date

    init(title: String, description: String, timestamp: Date) {
        self.title = title
        self.description = description
        self.timestamp = timestamp
    }
}

fileprivate extension Date {
    static var random: Date {
        Date(timeIntervalSince1970: TimeInterval.random(in: 0...1_000_000_000))
    }
}

extension Array<TableItem> {
    // 10 examples of TableItems. Each has a random timestamp, it's title
    // is the name of a famous novel, and the subtitle is the author's name.
    static let exampleData: [TableItem] = [
        TableItem(title: "The Great Gatsby", description: "F. Scott Fitzgerald", timestamp: Date.random),
        TableItem(title: "The Adventures of Huckleberry Finn", description: "Mark Twain", timestamp: Date.random),
        TableItem(title: "The Catcher in the Rye", description: "J. D. Salinger", timestamp: Date.random),
        TableItem(title: "The Grapes of Wrath", description: "John Steinbeck", timestamp: Date.random),
        TableItem(title: "To Kill a Mockingbird", description: "Harper Lee", timestamp: Date.random),
        TableItem(title: "The Color Purple", description: "Alice Walker", timestamp: Date.random),
        TableItem(title: "Ulysses", description: "James Joyce", timestamp: Date.random),
        TableItem(title: "Beloved", description: "Toni Morrison", timestamp: Date.random),
        TableItem(title: "The Lord of the Rings", description: "J. R. R. Tolkien", timestamp: Date.random),
        TableItem(title: "1984", description: "George Orwell", timestamp: Date.random)
    ]
}

struct MacPOITable: View {
    let data: [TableItem]

    @State private var selection = Set<TableItem.ID>()
    @State private var sortOrder = [KeyPathComparator(\TableItem.timestamp)]

    var body: some View {
        Table(of: TableItem.self,
              selection: $selection,
              sortOrder: $sortOrder
        ) {
            // Define Columns
            TableColumn("Date Created", value: \.timestamp) { tableItem in
                Text(tableItem.timestamp, format: .dateTime.day().month(.wide).year())
                    .monospacedDigit()
            }
            TableColumn("Title", value: \.title) { tableItem in
                Text(tableItem.title)
            }
            TableColumn("Description", value: \.description) { tableItem in
                Text(tableItem.description)
            }
        } rows: {
            ForEach(data.sorted(using: sortOrder)) { tableItem in
                TableRow(tableItem)
            }
        }
    }
}

struct MacPOITable_Previews: PreviewProvider {
    static var previews: some View {
        MacPOITable(data: .exampleData)
    }
}


