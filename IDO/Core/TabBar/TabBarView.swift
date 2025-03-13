//
//  TabBarView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 5/3/25.
//

import SwiftUI

struct TabBarView: View {
    
    var body: some View {
        TabView {
            ExploreView()
                .tabItem {
                    Label("Notes", systemImage: "list.clipboard")
                }
                
            ChatsView()
                .tabItem {
                    Label("AI Chat", systemImage: "brain.head.profile")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    TabBarView()
}
