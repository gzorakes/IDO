//
//  OnboardingIntroView.swift
//  IDO
//
//  Created by George Zorakis on 7/3/25.
//

import SwiftUI

struct OnboardingIntroView: View {
    
    @Environment(DependencyContainer.self) private var container
    
    var body: some View {
        VStack {
            Group {
                Text("Your ")
                +
                Text("wedding ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("simplified!\nOrganize every detail in one place.\n\n")
                +
                Text("Keep track with ")
                +
                Text("categories\n")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("for all your wedding details!")
            }
            .baselineOffset(6)
            .frame(maxHeight: .infinity)
            .padding(24)
            .fontDesign(.rounded)
            
            NavigationLink {
                OnboardingInfoView(viewModel: OnboardingInfoViewModel(interactor: CoreInteractor(container: container)))
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
        }
        .padding(24)
        .font(.title3)
        .screenAppearAnalytics(name: "OnboardingIntroView")
    }
        
}

#Preview {
    OnboardingIntroView()
        .previewEnvironment()
}
