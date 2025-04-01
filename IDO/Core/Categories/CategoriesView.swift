//
//  CategoriesView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
//

import SwiftUI

struct CategoriesView: View {
    
    @Environment(LogManager.self) private var logManager
    @Environment(PushManager.self) private var pushManager
    
    @State private var categories: [CategoryModel] = CategoryModel.allCategories
    @State private var path: [CategoryModel] = []
    @State private var showDevSettings: Bool = false
    @State private var showNotificationButton: Bool = false
    @State private var showPushNotificationModal: Bool = false
    
    private var showDevSettingsButton: Bool {
    #if DEV || MOCK
        return true
    #else
        return false
    #endif
    }
    
    var body: some View {
        NavigationStack(path: $path) {
                VStack {
                    categoriesGrid
                        .removeListRowFormatting()
                }
                .navigationTitle("Categories")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: CategoryModel.self) { newValue in
                    TodoListView(category: newValue)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if showDevSettingsButton {
                            devSettingsButton
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if showNotificationButton {
                            pushNotificationButton
                        }
                    }
                }
                .showModal(showModal: $showPushNotificationModal, content: {
                    pushNotificationModal
                })
                .sheet(isPresented: $showDevSettings) {
                    DevSettingsView()
                }
                .task {
                    await handleShowPushNotificationsButton()
                }
                .onFirstAppear {
                    schedulePushNotifications()
                }
                .screenAppearAnalytics(name: "CategoriesView")
        }
    }
    
    private var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappableBackground()
            .foregroundStyle(.accent)
            .anyButton {
                onPushNotificationPressed()
            }
    }
    
    private func schedulePushNotifications() {
        pushManager.schedulePushNotificationsForTheNextWeek()
    }
    
    private func handleShowPushNotificationsButton() async {
        showNotificationButton = await pushManager.canRequestAuthorization()
    }
    
    private func onPushNotificationPressed() {
        showPushNotificationModal = true
        logManager.trackEvent(event: Event.pushNotifsStart)
    }
    
    private func onEnablePushNotificationsPressed() {
        showPushNotificationModal = false
        
        Task {
            let isAuthorized = try await pushManager.requestAuthorization()
            logManager.trackEvent(event: Event.pushNotifsEnable(isAuthorized: isAuthorized))
            await handleShowPushNotificationsButton()
        }
    }
    
    private func onCancelPushNotificationsPressed() {
        showPushNotificationModal = false
        logManager.trackEvent(event: Event.pushNotifsCancel)
    }
    
    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable push notifications?",
            subtitle: "We'll send you reminders and updates!",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                onEnablePushNotificationsPressed()
            },
            secondaryButtonTitle: "Cancel") {
                onCancelPushNotificationsPressed()
            }
    }
        
    private var devSettingsButton: some View {
        Text("DEV ⚙️")
            .font(.footnote).bold()
            .foregroundStyle(.white)
            .padding(6)
            .background(.accent)
            .cornerRadius(8)
            .anyButton(.press) {
                onDevSettingsPressed()
            }
    }
    
    private func onDevSettingsPressed() {
        showDevSettings = true

    }
    
    private var categoriesGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: -30), count: 2),
            alignment: .center,
            spacing: 16,
            content: {
                Section {
                    ForEach(categories) { category in
                        HeroCellView(title: category.title, imageName: category.imageName, font: .callout)
                            .anyButton(.press) {
                                onCategoryPressed(category: category)
                            }
                            .frame(width: UIScreen.main.bounds.width / 2 - 32)
                            .frame(height: UIScreen.main.bounds.height / 10 )
                            .shadow(radius: 5)
                    }
                }
            }
        )
    }
    
    private func onCategoryPressed(category: CategoryModel) {
        path.append(category)
        logManager.trackEvent(event: Event.categoryPressed(category: category))
    }
    
    enum Event: LoggableEvent {
        case categoryPressed(category: CategoryModel)
        case pushNotifsStart
        case pushNotifsEnable(isAuthorized: Bool)
        case pushNotifsCancel
        
        var eventName: String {
            switch self {
            case .categoryPressed:     return "Categories_Category_Pressed"
            case .pushNotifsStart:     return "Categories_PushNotifs_Start"
            case .pushNotifsEnable:    return "Categories_PushNotifs_Enable"
            case .pushNotifsCancel:    return "Categories_PushNotifs_Cancel"

            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .categoryPressed(category: let category):
                return category.eventParameters
            case .pushNotifsEnable(isAuthorized: let isAuthorized):
                return [
                    "is_authorized": isAuthorized
                ]
            default:
                return nil
            }
            
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }

}

#Preview {
    CategoriesView()
        .previewEnvironment()
}
