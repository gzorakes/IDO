//
//  OnboardingInfoViewModel.swift
//  IDO
//
//  Created by George Zorakis on 18/4/25.
//
import SwiftUI


@MainActor
protocol OnboardingInfoInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingInfoInteractor { }

@Observable
@MainActor
class OnboardingInfoViewModel {
    private let interactor: OnboardingInfoInteractor
    
    var selectedColor: Color?
    var name: String = ""
    var weddingDate: Date?
    var daysUntilWedding: Int? {
        guard let weddingDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weddingDay = calendar.startOfDay(for: weddingDate)
        return calendar.dateComponents([.day], from: today, to: weddingDay).day
    }
    
    init(interactor: OnboardingInfoInteractor) {
        self.interactor = interactor
    }
    
    func onSelectRolePressed(color: Color, role: String) {
        selectedColor = color
        interactor.trackEvent(event: Event.roleSelected(role: role))
    }
    
    func onContinuePressed(path: Binding<[OnboardingPathOption]>) {
        guard let selectedColor, let weddingDate, let daysUntilWedding else { return }
        path.wrappedValue.append(.completedView(selectedColor: selectedColor, name: name, weddingDate: weddingDate, daysUntilWedding: daysUntilWedding))
    }
    
    enum Event: LoggableEvent {
        case roleSelected(role: String)
        
        var eventName: String {
            switch self {
            case .roleSelected: return "Onboarding_Role_Selected"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .roleSelected(let role):
                return ["role": role]
            }
        }
        
        var type: LogType {
            return .analytic
        }
    }
}

