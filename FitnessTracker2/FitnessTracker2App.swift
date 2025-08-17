//
//  FitnessTracker2App.swift
//  FitnessTracker2
//
//  Created by 沼田蓮二朗 on 2025/08/17.
//

import SwiftUI

@main
struct FitnessTracker2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
