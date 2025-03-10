//
//  OnboardingColorView.swift
//  IDO
//
//  Created by Γιωργος Ζωρακης on 7/3/25.
//

import SwiftUI

struct OnboardingColorView: View {

    @State private var selectedColor: Color?
    @State private var name: String = ""
    @State private var weddingDate: Date?
    
    var daysUntilWedding: Int? {
        guard let weddingDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weddingDay = calendar.startOfDay(for: weddingDate)
        return calendar.dateComponents([.day], from: today, to: weddingDay).day
    }

    var body: some View {
        List {
            Section("I am the...") {
                HStack(spacing: 30) {
                    Spacer()
                    rectangle(color: .pink, name: "Bride", isSelected: selectedColor == .pink)
                        .onTapGesture {
                            selectedColor = .pink
                        }
                    
                    rectangle(color: .blue, name: "Groom", isSelected: selectedColor == .blue)
                        .onTapGesture {
                            selectedColor = .blue
                        }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            
            Section("My name is...") {
                TextField("Name", text: $name)
            }
            
            Section("I am getting married on...") {
                DatePicker("Select Date", selection: Binding(
                    get: { weddingDate ?? Date() },
                    set: { weddingDate = $0 }
                ), displayedComponents: .date)
                .datePickerStyle(.compact)
            }
            
            if let daysLeft = daysUntilWedding {
                Section {
                    Text(daysLeft < 0 ? "😱" : "\(daysLeft)")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .background(LinearGradient(colors: [.blue.opacity(0.5), .pink.opacity(0.5)], startPoint: .bottomLeading, endPoint: .topTrailing))
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
                if selectedColor != nil && !name.isEmpty && weddingDate != nil {
                    ctaButton(selectedColor: selectedColor ?? .accent, name: name, daysUntilWedding: daysUntilWedding ?? 0)
                        .disabled(daysUntilWedding ?? 0 <= 0)
                }
            }
            .padding(24)
        })
    }
    
    private func rectangle(color: Color, name: String, isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(color.opacity(0.5))
            .frame(width: 80, height: 70)
            .overlay(alignment: .center) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? (selectedColor == .pink ? .blue.opacity(0.5) : .pink.opacity(0.5)) : .clear, lineWidth: 2)
            )
    }
    
    private func ctaButton(selectedColor: Color, name: String, daysUntilWedding: Int) -> some View {
        NavigationLink {
            OnboardingCompletedView(selectedColor: selectedColor, name: name, daysUntilWedding: daysUntilWedding)
        } label: {
            Text("Continue")
                .callToActionButton()
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingColorView()
    }
    .environment(AppState())
}
