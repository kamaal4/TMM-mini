//
//  TMM_MiniApp.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI
import CoreData
import Foundation

@main
struct TMM_MiniApp: App {
    let persistenceController = PersistenceController.shared

    init() {
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
