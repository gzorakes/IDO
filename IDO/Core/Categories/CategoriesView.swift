//
//  CategoriesView.swift
//  IDO
//
//  Created by George Zorakis on 5/3/25.
//

import SwiftUI

struct CategoriesView: View {
    
    @Environment(DependencyContainer.self) private var container
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
                    TodoListView(viewModel: TodoListViewModel(interactor: CoreInteractor(container: container)), category: newValue)
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
                    DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
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
        viewModel: CategoriesViewModel(interactor: CoreInteractor(container: DevPreview.shared.container))
    )
    .previewEnvironment()
}
