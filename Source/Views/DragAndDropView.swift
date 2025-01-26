import Combine
import SwiftUI

#Preview {
    DragAndDropView(layout: .Examples.complex)
}

@MainActor
struct DragAndDropView: View {
    @State var layout: DropLayout
    @State var currentItem: Item? = nil
    let containerRect = CGRect(origin: .zero, size: CGSize(width: 320, height: 320))

    var colors = [Color.cyan, .green, .purple, .pink, .orange]
    @State private var position: CGPoint = .init(x: -100, y: -100)

    var body: some View {
        VStack {
            DropLayoutView(layout: layout, dragGesture: { dragGesture(for: $0) })
                .animation(.default, value: layout)
                .frame(width: containerRect.width, height: containerRect.height)
            HStack {
                ForEach((0..<colors.count), id: \.self) { index in
                    colors[index]
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)
                        .gesture(createItemGesture(with: colors[index]))
                }
            }
        }
        .coordinateSpace(.named("Dropped"))
        .overlay(content: {
            if let currentItem,
               case .content(let color) = currentItem.itemType,
               !containerRect.contains(position) {
                color
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)
                    .position(position)
            }
        })
        .onChange(of: position) { oldValue, value in
            guard oldValue.distance(value) > 5 else {
                position = oldValue
                return
            }
            guard let currentItem else { return }
            DragAndDropView.updateLayout(with: currentItem, for: position, in: &layout, with: containerRect)
        }
    }

    // MARK: - Gestures

    private func createItemGesture(with color: Color) -> some Gesture {
        LongPressGesture(minimumDuration: 0)
            .map({ value in
                currentItem = Item(id: UUID(), itemType: .content(color))
            })
            .sequenced(before: dragGesture(for: nil))
    }

    private func dragGesture(for item: Item?) -> some Gesture {
        DragGesture(minimumDistance: 3, coordinateSpace: .named("Dropped"))

            .onChanged({ value in
                guard item != nil || currentItem != nil else {
                    return
                }
                if currentItem == nil {
                    currentItem = item
                    currentItem?.isSelected = true
                }
                position = value.location
            })
            .onEnded { value in

                guard let currentItem else {
                    return
                }
                self.currentItem?.isSelected = false
                DragAndDropView.updateLayout(with: currentItem, for: value.location, in: &layout, with: containerRect)
                self.currentItem = nil

            }
    }

    // MARK: - Update Layout

    static func updateLayout(with currentItem: Item, for position: CGPoint, in layout: inout DropLayout, with containerRect: CGRect) {
        layout.remove(currentItem)

        guard containerRect.contains(position) else { return }

        guard !layout.items.isEmpty else {
            layout.items.append(currentItem)
            return
        }

        insertItem(currentItem, in: position, to: &layout, with: containerRect)
    }

    static func insertItem(_ item: Item, in position: CGPoint, to layout: inout DropLayout, with container: CGRect) {
        if shouldEnter(in: container, point: position, in: layout) || layout.items.count < 2 {
            add(item: item, to: &layout, position: position, containerRect: container)
        } else {
            let (containerItem, index, rect) = findItem(at: position, in: layout, containerRect: container)
            switch containerItem.itemType {
            case .content:
                var newLayout = DropLayout(direction: getPreferredDirection(rect, position), items: [containerItem])
                if newLayout.direction == .vertical {
                    if rect.height / 2 < position.y {
                        newLayout.items.append(item)
                    } else {
                        newLayout.items.insert(item, at: 0)
                    }
                } else {
                    if rect.width / 2.0 < position.x {
                        newLayout.items.append(item)
                    } else {
                        newLayout.items.insert(item, at: 0)
                    }
                }

                layout.items[index] = .init(id: UUID(), itemType: .container(newLayout), isSelected: false)
            case .container(var subLayout):
                insertItem(item, in: position, to: &subLayout, with: rect)
                var newLayout = layout
                newLayout.items[index].itemType = .container(subLayout)
                layout = newLayout
            }
        }
    }

    static func add(item: Item, to layout: inout DropLayout, position: CGPoint, containerRect: CGRect) {
        let preferredDirection = getPreferredDirection(containerRect, position)
        if layout.direction != preferredDirection && layout.items.count > 1 {
            let newContainer = Item(id: UUID(), itemType: .container(layout))
            var newLayout = DropLayout(direction: preferredDirection, items: [newContainer])
            if newLayout.direction == .vertical {
                if containerRect.height / 2 < position.y {
                    newLayout.items.append(item)
                } else {
                    newLayout.items.insert(item, at: 0)
                }
            } else {
                if containerRect.width / 2.0 < position.x {
                    newLayout.items.append(item)
                } else {
                    newLayout.items.insert(item, at: 0)
                }
            }
            layout = newLayout
        } else {
            layout.direction = preferredDirection
            let insertIndex = findIndexForInsertion(in: layout, at: position, container: containerRect)
            layout.items.insert(item, at: insertIndex)
        }
    }

    // MARK: - Helpers

    static func findIndexForInsertion(in layout: DropLayout, at point: CGPoint, container: CGRect) -> Int {
        let itemsCount = layout.items.count
        let rectAxis = layout.direction == .vertical ? container.height : container.width
        let cellSize = rectAxis / CGFloat(itemsCount)
        let pointAxis = layout.direction == .vertical ? point.y - container.origin.y : point.x - container.origin.x
        return Int((pointAxis / cellSize).rounded())
    }

    static func findItem(at position: CGPoint, in layout: DropLayout, containerRect: CGRect) -> (Item, Int, CGRect) {
        switch layout.direction {
        case .horizontal:
            let sectionWidth = containerRect.width / CGFloat(layout.items.count)
            let index = Int(((position.x - containerRect.origin.x) / sectionWidth).rounded(.down))
            let rectOrigin = CGPoint(
                x: containerRect.origin.x + CGFloat(index) * sectionWidth,
                y: containerRect.origin.y
            )
            let rectSize = CGSize(width: sectionWidth, height: containerRect.height)
            return (layout.items[index], index, CGRect(origin: rectOrigin, size: rectSize))

        case .vertical:
            let sectionHeight = containerRect.height / CGFloat(layout.items.count)
            let index = Int((position.y - containerRect.origin.y) / sectionHeight)
            let rectOrigin = CGPoint(
                x: containerRect.origin.x,
                y: containerRect.origin.y + CGFloat(index) * sectionHeight
            )
            let rectSize = CGSize(width: containerRect.width, height: sectionHeight)
            return (layout.items[index], index, CGRect(origin: rectOrigin, size: rectSize))
        }
    }

    static func shouldEnter(in container: CGRect, point: CGPoint, borderInsets: CGFloat = 16, in layout: DropLayout) -> Bool {

        let innerContainer = container.insetBy(dx: borderInsets, dy: borderInsets)
        let itemsCount = layout.items.count
        let rectAxis = layout.direction == .vertical ? container.height : container.width
        let cellSize = rectAxis / CGFloat(itemsCount)
        let pointAxis = layout.direction == .vertical ? point.y - container.origin.y : point.x - container.origin.x
        let closestIndex = (pointAxis / cellSize)
        return !innerContainer.contains(point) || abs(closestIndex.rounded() - closestIndex) < 0.1
    }


    static func getPreferredDirection(_ containerRect: CGRect, _ position: CGPoint) -> DropLayout.Direction {
        if containerRect.insetBy(dx: 0, dy: containerRect.height * 0.2).contains(position) {
            .horizontal
        } else {
            .vertical
        }
    }
}

extension CGPoint {
    func distance(_ other: CGPoint) -> CGFloat {
        sqrt(pow(x - other.x, 2) + pow(y - other.y, 2))
    }
}
