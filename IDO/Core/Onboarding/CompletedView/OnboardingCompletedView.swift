//
//  OnboardingCompletedView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager

    @State private var isCompletingProfileSetup: Bool = false
    @State private var showAlert: AnyAppAlert?

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
        .showCustomAlert(alert: $showAlert)
    }
    
    
    enum Event: LoggableEvent {
        case finishStart
        case finishSuccess(hex: String)
        case finishFail(error: Error)
        
        var eventName: String {
            switch self {
            case .finishStart:       return "OnboardingCompletedView_Finish_Start"
            case .finishSuccess:     return "OnboardingCompletedView_Finish_Success"
            case .finishFail:        return "OnboardingCompletedView_Finish_Fail"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .finishSuccess(hex: let hex):
                return [
                    "profile_color_hex": hex
                ]
            case .finishFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
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
        logManager.trackEvent(event: Event.finishStart)
        
        Task {
            do {
                let hex = selectedColor.asHex()
                try await userManager.markOnboardingCompleteForCurrentUser(profileColorHex: hex, name: name, weddingDate: weddingDate)
                logManager.trackEvent(event: Event.finishSuccess(hex: hex))

                // dismiss screen
                isCompletingProfileSetup = false
                root.updateViewState(showTabBarView: true)
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.finishFail(error: error))
            }
        }
    }
}

#Preview {
    OnboardingCompletedView(selectedColor: .blue, name: "George", weddingDate: .now, daysUntilWedding: 15)
        .environment(UserManager(services: MockUserServices()))
        .previewEnvironment()
}
