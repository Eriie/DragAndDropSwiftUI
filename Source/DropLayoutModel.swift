import SwiftUI

struct Item: Identifiable, Equatable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id && lhs.isSelected == rhs.isSelected
    }

    enum ItemType {
        case content(Color)
        case container(DropLayout)
    }
    let id: UUID
    var itemType: ItemType
    var isSelected: Bool = false

    var containerLayout: DropLayout? {
        switch itemType {
        case .container(let layout):
            return layout
        default:
            return nil
        }
    }
}

struct DropLayout: Equatable {
    enum Direction {
        case horizontal
        case vertical
    }
    var direction: Direction
    var items: [Item]

    func isItemContains(_ item: Item) -> Bool {
        items.contains(where: {
            if item.id == $0.id {
                true
            } else  if case .container(let layout) = item.itemType {
                layout.isItemContains(item)
            } else {
                false
            }
        })
    }

    func position(for index: Int, for size: CGSize) -> CGPoint {
        switch direction {
        case .horizontal:
            let x = cellWidth(for: size) * CGFloat(index) + (size.width / (CGFloat(items.count) * 2.0))
            return CGPoint(x: x, y: size.height / 2.0)
        case .vertical:
            let y = cellHeight(for: size) * CGFloat(index) + (size.height / (CGFloat(items.count) * 2.0))
            return CGPoint(x: size.width / 2.0, y: y)
        }
    }

    func cellWidth(for size: CGSize) -> CGFloat {
        if direction == .horizontal {
            size.width / CGFloat(items.count)
        } else {
            size.width
        }
    }

    func cellHeight(for size: CGSize) -> CGFloat {
        if direction == .horizontal {
            size.height
        } else {
            size.height / CGFloat(items.count)
        }
    }

    mutating func remove(_ itemToRemove: Item) {
        items.removeAll { $0.id == itemToRemove.id }
        var indexesToRemove = [Int]()
        for index in items.indices {
            switch items[index].itemType {
            case .content:
                continue
            case .container(var dropLayout):
                dropLayout.remove(itemToRemove)
                // Update the container with the modified layout
                if dropLayout.items.count < 2 {
                    if let movingItem = dropLayout.items.first {
                        items[index] = movingItem
                    } else {
                        indexesToRemove.append(index)
                    }
                } else {
                    items[index] = .init(id: UUID(), itemType: .container(dropLayout))
                }
            }
        }
        indexesToRemove.reversed().forEach({ items.remove(at: $0) })
        if items.count < 2, case .container(let subLayout) = items.first?.itemType {
            items = subLayout.items
            direction = subLayout.direction
        }
    }
}

extension DropLayout {
    enum Examples {

        static let twoColumns: DropLayout = .init(
            direction: .horizontal,
            items: [

            ]
        )

        static let complex: DropLayout = DropLayout(
            direction: .horizontal,
            items: [
                Item(id: UUID(), itemType: .content(.blue)),
                Item(id: UUID(), itemType: .container(DropLayout(direction: .vertical, items: [
                    Item(id: UUID(), itemType: .content(.red)),
                    Item(id: UUID(), itemType: .container(DropLayout(direction: .horizontal, items: [
                        Item(id: UUID(), itemType: .content(.yellow)),
                        Item(id: UUID(), itemType: .content(.purple)),
                        Item(id: UUID(), itemType: .content(.orange))
                    ]))),
                    Item(id: UUID(), itemType: .content(.green))
                ]))),
            ]
        )
    }
}
