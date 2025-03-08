//
//  WelcomeView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 5/3/25.
//

import SwiftUI

struct WelcomeView: View {
    
    @State var imageName: String = Constants.randomImage
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8.0) {
                Image("welcomephoto")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                titleSection
                    .padding(.top, 24)
                    .fontDesign(.rounded)
                
                ctaButtons
                    .padding(16)
                
                policyLinks
            }
        }
    }
    
    private var titleSection: some View {
        VStack {
            Text("Yes I Do! 💍")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
            
            Text("by George Zorakis")
                .font(.caption)
                .foregroundStyle(.secondary)
            
        }
    }
    
    private var ctaButtons: some View {
        VStack {
            Text("Already have an account? Sign in!")
                .foregroundStyle(.accent)
                .underline()
                .font(.body)
                .padding(8)
                .tappableBackground()
                .onTapGesture {
                    
                }
            NavigationLink {
                OnboardingIntroView()
            } label: {
                Text("Get Started")
                    .callToActionButton()
            }
        }
    }
    
    private var policyLinks: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.termsOfServiceUrl)!) {
                Text("Terms of Service")
            }
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            Link(destination: URL(string: Constants.privacyPolicyUrl)!) {
                Text("Privacy Policy")
            }
        }
    }
}

#Preview {
    WelcomeView()
}
