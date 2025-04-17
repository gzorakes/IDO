//
//  OnboardingInfoView.swift
//  IDO
//
//  Created by George Zorakis on 7/3/25.
//

import SwiftUI


struct OnboardingInfoView: View {
    
    @State var viewModel: OnboardingInfoViewModel
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        List {
            Section("I am the...") {
                HStack(spacing: 30) {
                    Spacer()
                    rectangle(color: .customPink, name: "Bride", isSelected: viewModel.selectedColor == .customPink)
                        .onTapGesture {
                            viewModel.onSelectRolePressed(color: .customPink, role: "Bride")
                        }
                    
                    rectangle(color: .accent, name: "Groom", isSelected: viewModel.selectedColor == .accent)
                        .onTapGesture {
                            viewModel.onSelectRolePressed(color: .accent, role: "Groom")
                        }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            
            Section("My name is...") {
                TextField("Name", text: $viewModel.name)
            }
            
            Section("I am getting married on...") {
                DatePicker("Select Date", selection: Binding(
                    get: { viewModel.weddingDate ?? Date() },
                    set: { viewModel.weddingDate = $0 }
                ), displayedComponents: .date)
                .datePickerStyle(.compact)
            }
            
            if let daysLeft = viewModel.daysUntilWedding {
                Section {
                    Text(daysLeft < 0 ? "😱" : "\(daysLeft)")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .background(LinearGradient(colors: [.accent, .customPink], startPoint: .bottomLeading, endPoint: .topTrailing))
                        .cornerRadius(12)
                        
                } footer: {
                    Text(daysLeft < 0 ? "This date has already passed!" :"Days left until the wedding")
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16, content: {
            ZStack {
                if viewModel.selectedColor != nil && !viewModel.name.isEmpty && viewModel.weddingDate != nil {
                    ctaButton(
                        selectedColor: viewModel.selectedColor ?? .accent,
                        name: viewModel.name,
                        daysUntilWedding: viewModel.daysUntilWedding ?? 0
                    )
                    .disabled(viewModel.daysUntilWedding ?? 0 <= 0)
                }
            }
            .padding(24)
        })
        .screenAppearAnalytics(name: "OnboardingInfoView")
    }
    
    private func rectangle(color: Color, name: String, isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(color)
            .frame(width: 80, height: 70)
            .overlay(alignment: .center) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? (viewModel.selectedColor == .customPink ? .accent : .customPink) : .clear, lineWidth: 2)
            )
    }
    
    private func ctaButton(selectedColor: Color, name: String, daysUntilWedding: Int) -> some View {
        NavigationLink {
            OnboardingCompletedView(
                viewModel: OnboardingCompletedViewModel(interactor: CoreInteractor(container: container)),
                selectedColor: selectedColor,
                name: name,
                weddingDate: viewModel.weddingDate ?? .now,
                daysUntilWedding: daysUntilWedding)
        } label: {
            Text("Continue")
                .callToActionButton()
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingInfoView(viewModel: OnboardingInfoViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
    }
    .previewEnvironment()
}
