//
//  AddWaterSheet.swift
//  Project2026
//
//  Sheet for adding custom water amount
//

import SwiftUI

public struct AddWaterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var waterService: WaterService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var customAmount: String = ""
    @State private var selectedPreset: WaterQuickAdd?
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Current Progress
                VStack(spacing: 8) {
                    Text("Today's Progress")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(waterService.todayTotal))oz")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("of \(Int(waterService.dailyTarget))oz goal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: waterService.todayProgress)
                        .tint(.blue)
                        .padding(.horizontal, 40)
                }
                .padding(.top)
                
                Divider()
                
                // Quick Add Buttons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Add")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(WaterQuickAdd.allCases, id: \.rawValue) { option in
                            Button {
                                selectedPreset = option
                                customAmount = ""
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: option.icon)
                                        .font(.title2)
                                    Text(option.displayText)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(selectedPreset == option ? Color.blue : Color.blue.opacity(0.1))
                                .foregroundColor(selectedPreset == option ? .white : .blue)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Custom Amount
                VStack(alignment: .leading, spacing: 12) {
                    Text("Custom Amount")
                        .font(.headline)
                    
                    HStack {
                        TextField("Enter ounces", text: $customAmount)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: customAmount) { _, _ in
                                selectedPreset = nil
                            }
                        
                        Text("oz")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Add Button
                Button {
                    Task {
                        if let preset = selectedPreset {
                            await waterService.addWater(quickAdd: preset)
                        } else if let amount = Double(customAmount), amount > 0 {
                            await waterService.addWater(amount)
                        }
                        dismiss()
                    }
                } label: {
                    Text("Add Water")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isValid)
                .padding(.horizontal)
                
                // Undo Last Entry
                if !waterService.todayLog.entries.isEmpty {
                    Button {
                        Task {
                            await waterService.removeLastEntry()
                        }
                    } label: {
                        Label("Undo Last Entry", systemImage: "arrow.uturn.backward")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.bottom)
            .navigationTitle("Add Water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isValid: Bool {
        selectedPreset != nil || (Double(customAmount) ?? 0) > 0
    }
}

#Preview {
    AddWaterSheet()
        .environmentObject(WaterService())
        .environmentObject(ThemeService())
}
