//
//  DropApp.swift
//  Drop
//
//  Created by Valentin Borodkin on 19.01.2025.
//

import SwiftUI

@main
struct DropApp: App {
    var body: some Scene {
        WindowGroup {
            DragAndDropView(layout: .init(direction: .vertical, items: []))
        }
    }
}
