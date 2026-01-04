//
//  ContentView.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//
//  NOTE: This file is no longer used. The app uses RootView instead.
//  Keeping for reference or can be deleted.

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        Text("This view is deprecated. Use RootView instead.")
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
