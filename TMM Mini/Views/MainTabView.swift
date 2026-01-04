//
//  MainTabView.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI
import CoreData

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Summary", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)
            
            NutritionLogView()
                .tabItem {
                    Label("Log", systemImage: selectedTab == 1 ? "plus.circle.fill" : "plus.circle")
                }
                .tag(1)
            
            // Placeholder for future screens
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 2 ? "person.fill" : "person")
                }
                .tag(2)
        }
        .accentColor(.primaryColor)
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

