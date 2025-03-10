//
//  OnboardingIntroView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 7/3/25.
//

import SwiftUI

struct OnboardingIntroView: View {
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
                Text("Get ideas generated from ")
                +
                Text("AI ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("and have ")
                +
                Text("real conversations")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("!")
            }
            .baselineOffset(6)
            .frame(maxHeight: .infinity)
            .padding(24)
            .fontDesign(.rounded)
            
            NavigationLink {
                OnboardingColorView()
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
        }
        .padding(24)
        .font(.title3)
    }
}

#Preview {
    OnboardingIntroView()
}
