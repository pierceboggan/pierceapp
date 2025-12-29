import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var showingExport = false
    @State private var exportedText = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Weekly Summary")) {
                    if !viewModel.weeklySummaries.isEmpty {
                        WeeklySummaryView(summaries: viewModel.weeklySummaries)
                    } else {
                        Text("No data yet")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Daily History")) {
                    ForEach(viewModel.summaries) { summary in
                        DaySummaryRow(summary: summary)
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        exportedText = viewModel.generateChatGPTExport()
                        showingExport = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingExport) {
                ExportView(text: exportedText)
            }
            .onAppear {
                viewModel.loadSummaries()
            }
        }
    }
}

struct WeeklySummaryView: View {
    let summaries: [DaySummary]
    
    var averageScore: Double {
        guard !summaries.isEmpty else { return 0 }
        return summaries.reduce(0.0) { $0 + $1.score } / Double(summaries.count)
    }
    
    var habitCompliance: Double {
        let totalCompleted = summaries.reduce(0) { $0 + $1.habitsCompleted }
        let totalAvailable = summaries.reduce(0) { $0 + $1.habitsTotal }
        guard totalAvailable > 0 else { return 0 }
        return Double(totalCompleted) / Double(totalAvailable) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Average Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(averageScore))%")
                        .font(.title2)
                        .bold()
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Habit Compliance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(habitCompliance))%")
                        .font(.title2)
                        .bold()
                }
            }
            
            Text("\(summaries.count) days tracked")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct DaySummaryRow: View {
    let summary: DaySummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(summary.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Spacer()
                Text("\(Int(summary.score))%")
                    .font(.title3)
                    .bold()
                    .foregroundColor(scoreColor(summary.score))
            }
            
            HStack {
                Label("\(summary.habitsCompleted)/\(summary.habitsTotal)", systemImage: "checkmark.circle")
                    .font(.caption)
                Spacer()
                Label("\(summary.waterConsumed)oz", systemImage: "drop.fill")
                    .font(.caption)
                Spacer()
                Label("\(summary.pagesRead)pg", systemImage: "book.fill")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func scoreColor(_ score: Double) -> Color {
        if score >= 80 {
            return .green
        } else if score >= 60 {
            return .orange
        } else {
            return .red
        }
    }
}

struct ExportView: View {
    let text: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(text)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .navigationTitle("ChatGPT Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        UIPasteboard.general.string = text
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryView()
}
