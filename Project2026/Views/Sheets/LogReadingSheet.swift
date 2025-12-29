//
//  LogReadingSheet.swift
//  Project2026
//
//  Sheet for logging reading progress
//

import SwiftUI

struct LogReadingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var readingService: ReadingService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var selectedBook: Book?
    @State private var pagesRead: String = ""
    @State private var durationMinutes: String = ""
    @State private var note: String = ""
    @State private var logType: LogType = .pagesRead
    
    enum LogType {
        case pagesRead
        case currentPage
    }
    
    private var theme: AppTheme { themeService.currentTheme }
    private var currentBooks: [Book] { readingService.currentlyReading }
    
    var body: some View {
        NavigationStack {
            Form {
                // Book Selection
                if currentBooks.count > 1 {
                    Section("Select Book") {
                        Picker("Book", selection: $selectedBook) {
                            ForEach(currentBooks) { book in
                                Text(book.title).tag(book as Book?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } else if let book = currentBooks.first {
                    Section {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                Text(book.author)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(book.progressPercentage)%")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        }
                    }
                }
                
                // Log Type
                Section {
                    Picker("Log Type", selection: $logType) {
                        Text("Pages Read").tag(LogType.pagesRead)
                        Text("Current Page").tag(LogType.currentPage)
                    }
                    .pickerStyle(.segmented)
                }
                
                // Pages Input
                Section {
                    if logType == .pagesRead {
                        HStack {
                            Text("Pages Read")
                            Spacer()
                            TextField("0", text: $pagesRead)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                    } else {
                        HStack {
                            Text("Current Page")
                            Spacer()
                            TextField("\(selectedBook?.currentPage ?? 0)", text: $pagesRead)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("/ \(selectedBook?.totalPages ?? 0)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Duration (Optional)
                Section("Duration (Optional)") {
                    HStack {
                        Text("Minutes")
                        Spacer()
                        TextField("0", text: $durationMinutes)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                // Note (Optional)
                Section("Note (Optional)") {
                    TextField("Add a note about your reading...", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Book Info
                if let book = selectedBook ?? currentBooks.first {
                    Section("Progress After") {
                        let newPage = calculateNewPage(book: book)
                        let newProgress = Double(newPage) / Double(book.totalPages)
                        
                        HStack {
                            Text("Page")
                            Spacer()
                            Text("\(newPage) / \(book.totalPages)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Progress")
                            Spacer()
                            Text("\(Int(newProgress * 100))%")
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: newProgress)
                            .tint(.orange)
                    }
                }
            }
            .navigationTitle("Log Reading")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReading()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                selectedBook = currentBooks.first
            }
        }
    }
    
    private var isValid: Bool {
        guard let pages = Int(pagesRead), pages > 0 else { return false }
        guard selectedBook != nil || currentBooks.first != nil else { return false }
        return true
    }
    
    private func calculateNewPage(book: Book) -> Int {
        guard let pages = Int(pagesRead) else { return book.currentPage }
        
        if logType == .pagesRead {
            return min(book.currentPage + pages, book.totalPages)
        } else {
            return min(pages, book.totalPages)
        }
    }
    
    private func saveReading() {
        guard let book = selectedBook ?? currentBooks.first,
              let pages = Int(pagesRead), pages > 0 else { return }
        
        let duration = Int(durationMinutes)
        
        Task {
            if logType == .pagesRead {
                await readingService.logReading(
                    book: book,
                    pagesRead: pages,
                    durationMinutes: duration,
                    note: note.isEmpty ? nil : note
                )
            } else {
                await readingService.updateProgress(book: book, currentPage: pages)
            }
            dismiss()
        }
    }
}

#Preview {
    LogReadingSheet()
        .environmentObject(ReadingService())
        .environmentObject(ThemeService())
}
