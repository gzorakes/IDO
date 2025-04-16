//
//  CategoriesView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
//

import SwiftUI


@Observable
@MainActor
class CategoriesViewModel {
    let container: DependencyContainer
    private let logManager: LogManager
    private let pushManager: PushManager
    
    init(container: DependencyContainer) {
        self.container = container
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
    }
    
    private(set) var categories: [CategoryModel] = CategoryModel.allCategories
    private(set) var showNotificationButton: Bool = false
    
    var path: [CategoryModel] = []
    var showDevSettings: Bool = false
    var showPushNotificationModal: Bool = false
    
    var showDevSettingsButton: Bool {
    #if DEV || MOCK
        return true
    #else
        return false
    #endif
    }
    
    func schedulePushNotifications() {
        pushManager.schedulePushNotificationsForTheNextWeek()
    }
    
    func handleShowPushNotificationsButton() async {
        showNotificationButton = await pushManager.canRequestAuthorization()
    }
    
    func onPushNotificationPressed() {
        showPushNotificationModal = true
        logManager.trackEvent(event: Event.pushNotifsStart)
    }
    
    func onEnablePushNotificationsPressed() {
        showPushNotificationModal = false
        
        Task {
            let isAuthorized = try await pushManager.requestAuthorization()
            logManager.trackEvent(event: Event.pushNotifsEnable(isAuthorized: isAuthorized))
            await handleShowPushNotificationsButton()
        }
    }
    
    func onCancelPushNotificationsPressed() {
        showPushNotificationModal = false
        logManager.trackEvent(event: Event.pushNotifsCancel)
    }
    
    func onDevSettingsPressed() {
        showDevSettings = true
    }
    
    func onCategoryPressed(category: CategoryModel) {
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


struct CategoriesView: View {
    
    @State var viewModel: CategoriesViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
                VStack {
                    categoriesGrid
                        .removeListRowFormatting()
                }
                .navigationTitle("Categories")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: CategoryModel.self) { newValue in
                    TodoListView(viewModel: TodoListViewModel(container: viewModel.container), category: newValue)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if viewModel.showDevSettingsButton {
                            devSettingsButton
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if viewModel.showNotificationButton {
                            pushNotificationButton
                        }
                    }
                }
                .showModal(showModal: $viewModel.showPushNotificationModal, content: {
                    pushNotificationModal
                })
                .sheet(isPresented: $viewModel.showDevSettings) {
                    DevSettingsView()
                }
                .task {
                    await viewModel.handleShowPushNotificationsButton()
                }
                .onFirstAppear {
                    viewModel.schedulePushNotifications()
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
                viewModel.onPushNotificationPressed()
            }
    }
    
    
    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable push notifications?",
            subtitle: "We'll send you reminders and updates!",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                viewModel.onEnablePushNotificationsPressed()
            },
            secondaryButtonTitle: "Cancel") {
                viewModel.onCancelPushNotificationsPressed()
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
                viewModel.onDevSettingsPressed()
            }
    }
    
    
    private var categoriesGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: -30), count: 2),
            alignment: .center,
            spacing: 16,
            content: {
                Section {
                    ForEach(viewModel.categories) { category in
                        HeroCellView(title: category.title, imageName: category.imageName, font: .callout)
                            .anyButton(.press) {
                                viewModel.onCategoryPressed(category: category)
                            }
                            .frame(width: UIScreen.main.bounds.width / 2 - 32)
                            .frame(height: UIScreen.main.bounds.height / 10 )
                            .shadow(radius: 5)
                    }
                }
            }
        )
    }
}

#Preview {
    CategoriesView(
        viewModel: CategoriesViewModel(container: DevPreview.shared.container)
    )
    .previewEnvironment()
}
