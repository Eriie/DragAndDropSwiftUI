import SwiftUI

struct DropLayoutView<DragDropGesture: Gesture>: View {
    var layout: DropLayout
    let dragGesture: (Item) -> DragDropGesture

    var body: some View {

        GeometryReader { reader in
            ForEach(0..<layout.items.count, id: \.self) { index in
                itemView(item: layout.items[index])
                    .frame(width: layout.cellWidth(for: reader.size), height: layout.cellHeight(for: reader.size))
                    .position(layout.position(for: index, for: reader.size))
            }
        }
        .overlay {
            if layout.items.isEmpty {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray)
            }
        }
    }

    @ViewBuilder
    func itemView(item: Item) -> some View {
        switch item.itemType {
        case .content(let color):
            VStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color)
                    .padding(.all, 6)
                    .shadow(radius: item.isSelected ? 10 : 0)
                    .gesture(dragGesture(item))
            }

        case .container(let dropLayout):
            DropLayoutView(layout: dropLayout, dragGesture: dragGesture)
        }
    }
}
