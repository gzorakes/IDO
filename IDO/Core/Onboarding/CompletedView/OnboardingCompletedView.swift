//
//  OnboardingCompletedView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 5/3/25.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
    @State private var isCompletingProfileSetup: Bool = false
    var selectedColor: Color
    var name: String
    var daysUntilWedding: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome \(name)!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor.opacity(0.5))
            
            Text("We have \(daysUntilWedding) days to prepare everything for the wedding.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            ctaButton
        })
        .padding(24)
    }
    
    private var ctaButton: some View {
        Button {
            onFinishButtonPressed()
        } label: {
            ZStack {
                if isCompletingProfileSetup {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Let's get started!")
                }
            }
            .callToActionButton()
        }
        .disabled(isCompletingProfileSetup)
    }
    
    func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        
        Task {
            try await Task.sleep(for: .seconds(3))
            isCompletingProfileSetup = false
            // other logic to complete onboarding
            root.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    OnboardingCompletedView(selectedColor: .blue, name: "George", daysUntilWedding: 15)
        .environment(AppState())
}
