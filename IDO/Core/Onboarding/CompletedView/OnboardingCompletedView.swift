//
//  OnboardingCompletedView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
//

import SwiftUI


struct OnboardingCompletedView: View {
    
    @State var viewModel: OnboardingCompletedViewModel

    var selectedColor: Color
    var name: String
    var weddingDate: Date
    var daysUntilWedding: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome \(name)!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)
            
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
        .screenAppearAnalytics(name: "OnboardingCompletedView")
        .showCustomAlert(alert: $viewModel.showAlert)
    }
    
    
    private var ctaButton: some View {
        Button {
            viewModel.onFinishButtonPressed(selectedColor: selectedColor, name: name, weddingDate: weddingDate)
        } label: {
            ZStack {
                if viewModel.isCompletingProfileSetup {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Let's get started!")
                }
            }
            .callToActionButton()
        }
        .disabled(viewModel.isCompletingProfileSetup)
    }
}

#Preview {
    OnboardingCompletedView(
        viewModel: OnboardingCompletedViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)),
        selectedColor: .blue,
        name: "George",
        weddingDate: .now,
        daysUntilWedding: 15
    )
    .previewEnvironment()
}
