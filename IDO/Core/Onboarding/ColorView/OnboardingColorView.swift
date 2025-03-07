//
//  OnboardingColorView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 7/3/25.
//

import SwiftUI

struct OnboardingColorView: View {
    
    struct ProfileIcon: Identifiable {
        let id = UUID()
        let role: String
        let icon: String
        let color: Color
    }
    
    let profileIcons: [ProfileIcon] = [
        ProfileIcon(role: "Groom", icon: "🤵🏻", color: .accent),
        ProfileIcon(role: "Bride", icon: "👰🏻‍♀️", color: .pink),
        ProfileIcon(role: "Best Man", icon: "🧔🏻", color: .blue),
        ProfileIcon(role: "Bridesmaid", icon: "👩🏻‍🦱", color: .orange),
        ProfileIcon(role: "Father", icon: "👨🏻", color: .green),
        ProfileIcon(role: "Mother", icon: "👩🏻", color: .purple),
        ProfileIcon(role: "Brother", icon: "🧑🏻", color: .cyan),
        ProfileIcon(role: "Sister", icon: "👱🏻‍♀️", color: .yellow),
        ProfileIcon(role: "Friend", icon: "👫", color: .gray)
    ]
    
    @State private var selectedIcon: ProfileIcon?
    
    var body: some View {
        ScrollView {
            colorGrid
                .padding(.horizontal)
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16, content: {
            ZStack {
                if selectedIcon != nil {
                    ctaButton
                        .transition(AnyTransition.move(edge: .bottom))
                }
            }
            .padding(24)
            .background(Color(uiColor: .systemBackground))
        })
        .animation(.bouncy, value: selectedIcon?.id)
    }
    
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
            alignment: .center,
            spacing: 16,
            pinnedViews: [.sectionHeaders],
            content: {
                Section(content: {
                    ForEach(profileIcons) { profile in
                        Circle()
                            .fill(profile.color)
                            .overlay(
                                VStack {
                                    Text(profile.icon)
                                        .font(.system(size: 40))
                                    Text(profile.role)
                                        .font(.caption)
                                }
                            )
                            .overlay(
                                Circle()
                                    .stroke(selectedIcon?.id == profile.id ? Color.red : Color.clear, lineWidth: 5)
                            )
                            .onTapGesture {
                                selectedIcon = profile
                            }
                        
                    }
                }, header: {
                    Text("Select a profile")
                })
            }
        )
    }
    
    private var ctaButton: some View {
        NavigationLink {
            OnboardingCompletedView()
        } label: {
            Text("Continue")
                .callToActionButton()
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingColorView()
    }
}
