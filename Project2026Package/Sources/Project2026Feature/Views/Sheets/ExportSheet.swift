//
//  ExportSheet.swift
//  Project2026
//
//  Sheet for exporting data to ChatGPT
//

import SwiftUI

public struct ExportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var daySummaryService: DaySummaryService
    @EnvironmentObject var habitService: HabitService
    @EnvironmentObject var readingService: ReadingService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var exportType: ExportType = .weekly
    @State private var selectedDate: Date = Date()
    @State private var generatedExport: String = ""
    @State private var showingShareSheet = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    enum ExportType: String, CaseIterable {
        case weekly = "Weekly Review"
        case daily = "Daily Summary"
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Export Type Selection
                Picker("Export Type", selection: $exportType) {
                    ForEach(ExportType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: exportType) { _, _ in
                    generateExport()
                }
                
                // Date Selection
                if exportType == .daily {
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .padding(.horizontal)
                    .onChange(of: selectedDate) { _, _ in
                        generateExport()
                    }
                }
                
                // Preview
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Preview")
                            .font(.headline)
                        Spacer()
                        Button {
                            UIPasteboard.general.string = generatedExport
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        Text(generatedExport)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Actions
                VStack(spacing: 12) {
                    Button {
                        UIPasteboard.general.string = generatedExport
                    } label: {
                        Label("Copy to Clipboard", systemImage: "doc.on.doc")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        showingShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.primary.opacity(0.1))
                            .foregroundColor(theme.primary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("Export for ChatGPT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                generateExport()
            }
            #if canImport(UIKit)
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [generatedExport])
            }
            #endif
        }
    }
    
    private func generateExport() {
        switch exportType {
        case .weekly:
            let weeklySummary = daySummaryService.weeklySummary(for: selectedDate)
            let reflections = weeklySummary.days.compactMap { $0.reflectionNote }
            
            generatedExport = ExportService.generateChatGPTSummary(
                goals: Goal.defaultHighLevelGoals + Goal.defaultKPIs,
                weeklySummary: weeklySummary,
                currentBooks: readingService.currentlyReading,
                reflectionNotes: reflections
            )
            
        case .daily:
            if let summary = daySummaryService.summaryForDate(selectedDate) {
                let habits = habitService.habitsForToday().map { habit in
                    (habit, habitService.logForHabit(habit.id, on: selectedDate))
                }
                
                generatedExport = ExportService.generateDailyExport(
                    summary: summary,
                    habits: habits,
                    cleaningTasks: [], // Would need cleaning service
                    currentBook: readingService.primaryBook
                )
            } else {
                generatedExport = "No data available for this date."
            }
        }
    }
}

// MARK: - Share Sheet

#if canImport(UIKit)
import UIKit

public struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

#Preview {
    ExportSheet()
        .environmentObject(DaySummaryService())
        .environmentObject(HabitService())
        .environmentObject(ReadingService())
        .environmentObject(ThemeService())
}
