//
//  OnboardingIntroViewModel.swift
//  IDO
//
//  Created by George Zorakis on 18/4/25.
//
import SwiftUI


@MainActor
protocol OnboardingIntroInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingIntroInteractor { }

@Observable
@MainActor
class OnboardingIntroViewModel {
    private let interactor: OnboardingIntroInteractor
    
    init(interactor: OnboardingIntroInteractor) {
        self.interactor = interactor
    }
    
    func onContinueButtonPressed(path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.infoView)
    }
}
