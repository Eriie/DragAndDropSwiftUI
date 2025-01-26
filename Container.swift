//import SwiftUI
//import UniformTypeIdentifiers
//
//struct ContentViewTest: View {
//    @State private var items: [Item] = [
//        Item(id: 1, size: .init(width: 2, height: 2), position: .init(x: 0, y: 0), colorModel: .init(colorName: "cyan")),
//        Item(id: 2, size: .init(width:2, height: 1), position: .init(x: 2,y: 0), colorModel: .init(colorName: "blue")),
//        Item(id: 3, size: .init(width: 1, height: 1), position: .init(x: 2,y: 2), colorModel: .init(colorName: "green"))
//    ]
//
//    var body: some View {
//        DragDropContainer(items: $items, gridSize: (4, 4))
//            .frame(width: 320, height: 320)
//            .border(Color.gray, width: 1)
//    }
//}
//
//struct DragDropContainer: View {
//    @Binding var items: [Item]
//    let gridSize: (Int, Int)
//    @State var cellWidth: CGFloat = 0
//    @State var cellHeight: CGFloat = 0
//    @State var currentItem: Item? = nil
//
//    var body: some View {
//        Color.white.opacity(0.1)
//            .overlay {
//                GeometryReader { geometry in
//                    let cellWidth = geometry.size.width / CGFloat(gridSize.0)
//                    let cellHeight = geometry.size.height / CGFloat(gridSize.1)
//
//                    ForEach(items) { item in
//                        Color(item.colorModel.colorName)
//                            .clipShape(RoundedRectangle(cornerRadius: 8))
//                            .onDrag({
//                                currentItem = item
//                                items.remove(at: items.firstIndex(of: item)!)
//                                return NSItemProvider()
//                            }, preview: {
//                                Color(item.colorModel.colorName)
//                                    .frame(width: 50, height: 50, alignment: .center)
//                            })
////                            .draggable(item, preview: {
////                                Color(item.colorModel.colorName)
////                                    .frame(width: 25, height: 25)
////                            })
//                            .frame(
//                                width: cellWidth * CGFloat(item.size.width),
//                                height: cellHeight * CGFloat(item.size.height)
//                            )
//                            .position(
//                                x: CGFloat(item.position.x) * cellWidth + cellWidth * CGFloat(item.size.width) / 2,
//                                y: CGFloat(item.position.y) * cellHeight + cellHeight * CGFloat(item.size.height) / 2
//                            )
//                            .onAppear(perform: {
//                                self.cellWidth = cellWidth
//                                self.cellHeight = cellHeight
//                            })
//                    }
//                }
//            }
//            .onDrop(of: [.testType], delegate: DragDropDelegate(items: $items, gridSize: (4,4), item: $currentItem))
////        .dropDestination(for: Item.self, action: { item, point in
////            updateItems(with: item.first!, at: point)
////            return true
////
////        })
//    }
//
//    func updateItems(with item: Item, at point: CGPoint) {
//        let x = Int(point.x / (cellWidth))
//        let y = Int(point.y / (cellHeight))
//        items.removeAll(where: { $0.id == item.id })
//
//        print(point)
//        print((cellWidth, cellHeight))
//        var item = item
//        item.position = .init(x: x, y: y)
//        items.append(item)
//    }
//
//    var itemView: some View {
//        Color.red
//            .clipShape(RoundedRectangle(cornerRadius: 8))
//            .onDrag({
//                NSItemProvider(object: String(items.first!.id) as NSString)
//            })
//
//    }
//}
//
//struct DragDropDelegate: DropDelegate {
//    @Binding var items: [Item]
//    let gridSize: (Int, Int)
//    @Binding var item:Item?
//
//
//    func dropUpdated(info: DropInfo) -> DropProposal? {
//        
//        return DropProposal.init(operation: .move)
//    }
//
//    func validateDrop(info: DropInfo) -> Bool {
//        info.hasItemsConforming(to: [.testType])
//    }
//
//    func dropEntered(info: DropInfo) {
//    }
//
//    func dropExited(info: DropInfo) { }
//
//    func performDrop(info: DropInfo) -> Bool {
//        guard var item else { return false }
//
//        items.append(item)
//        self.item = nil
//        return true
//    }
//
//    func updateItemsLayout(at newPosition: CGPoint) {
//        
//    }
//}
//
//extension UTType {
//    static var testType: UTType {
//        UTType(exportedAs: "com.test.type")
//    }
//}
//
//struct Item: Identifiable, Codable, Transferable, Equatable {
//    let id: Int^^
//    let colorModel: ColorModel
//
//    init(id: Int, size: IntSize, position: Point, colorModel: ColorModel) {
//        self.id = id
//        self.size = size
//        self.position = position
//        self.colorModel = colorModel
//    }
//
//    struct IntSize: Codable, Equatable {
//        let width: Int
//        let height: Int
//    }
//
//    struct Point: Codable, Equatable {
//        let x: Int
//        let y: Int
//    }
//
//    struct ColorModel: Codable, Equatable {
//        let colorName: String
//    }
//
//    static var transferRepresentation: some TransferRepresentation {
//        CodableRepresentation(for: Item.self, contentType: .testType)
//    }
//}
