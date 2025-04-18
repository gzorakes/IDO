//
//  OnboardingPathOption.swift
//  IDO
//
//  Created by George Zorakis on 18/4/25.
//

import SwiftUI

enum OnboardingPathOption: Hashable {
    case infoView
    case introView
    case completedView(selectedColor: Color, name: String, weddingDate: Date, daysUntilWedding: Int)
}

struct NavDestForOnboardingModuleViewModifier: ViewModifier {
    
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[OnboardingPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OnboardingPathOption.self) { newValue in
                switch newValue {
                case .infoView:
                    OnboardingInfoView(viewModel: OnboardingInfoViewModel(interactor: CoreInteractor(container: container)), path: path)
                case .introView:
                    OnboardingIntroView(viewModel: OnboardingIntroViewModel(interactor: CoreInteractor(container: container)), path: path)
                case .completedView(selectedColor: let selectedColor, name: let name, weddingDate: let weddingDate, daysUntilWedding: let daysUntilWedding):
                    OnboardingCompletedView(
                        viewModel: OnboardingCompletedViewModel(interactor: CoreInteractor(container: container)),
                        selectedColor: selectedColor,
                        name: name,
                        weddingDate: weddingDate,
                        daysUntilWedding: daysUntilWedding
                    )
                }
            }
    }
}

extension View {
    
    func navigationDestinationForOnboardingModule(path: Binding<[OnboardingPathOption]>) -> some View {
        modifier(NavDestForOnboardingModuleViewModifier(path: path))
    }
}
