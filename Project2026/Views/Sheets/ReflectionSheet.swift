//
//  ReflectionSheet.swift
//  Project2026
//
//  Sheet for adding daily reflection
//

import SwiftUI

struct ReflectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var daySummaryService: DaySummaryService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var reflectionText: String = ""
    @State private var hasLoaded = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Prompt
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Reflection")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Take a moment to reflect on your day. What went well? What could be improved?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
                
                // Reflection Prompts
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ReflectionPromptChip(text: "What am I grateful for?") {
                            appendPrompt("I'm grateful for ")
                        }
                        ReflectionPromptChip(text: "What did I learn?") {
                            appendPrompt("Today I learned ")
                        }
                        ReflectionPromptChip(text: "What could be better?") {
                            appendPrompt("I could improve ")
                        }
                        ReflectionPromptChip(text: "Tomorrow I will...") {
                            appendPrompt("Tomorrow I will ")
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Text Editor
                TextEditor(text: $reflectionText)
                    .frame(maxHeight: .infinity)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // Character Count
                HStack {
                    Spacer()
                    Text("\(reflectionText.count) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReflection()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadExistingReflection()
            }
        }
    }
    
    private func loadExistingReflection() {
        guard !hasLoaded else { return }
        hasLoaded = true
        
        if let summary = daySummaryService.todaySummary(),
           let note = summary.reflectionNote {
            reflectionText = note
        }
    }
    
    private func appendPrompt(_ prompt: String) {
        if reflectionText.isEmpty {
            reflectionText = prompt
        } else {
            reflectionText += "\n\n" + prompt
        }
    }
    
    private func saveReflection() {
        Task {
            await daySummaryService.updateReflection(
                for: Date(),
                note: reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            dismiss()
        }
    }
}

// MARK: - Reflection Prompt Chip

struct ReflectionPromptChip: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.teal.opacity(0.1))
                .foregroundColor(.teal)
                .cornerRadius(16)
        }
    }
}

#Preview {
    ReflectionSheet()
        .environmentObject(DaySummaryService())
        .environmentObject(ThemeService())
}
