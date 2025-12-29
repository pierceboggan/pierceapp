//
//  AddBookSheet.swift
//  Project2026
//
//  Sheet for adding a new book
//

import SwiftUI

struct AddBookSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var readingService: ReadingService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var totalPages: String = ""
    @State private var currentPage: String = "0"
    @State private var status: BookStatus = .currentlyReading
    
    private var theme: AppTheme { themeService.currentTheme }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Book Details") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    
                    HStack {
                        Text("Total Pages")
                        Spacer()
                        TextField("0", text: $totalPages)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section("Reading Status") {
                    Picker("Status", selection: $status) {
                        ForEach(BookStatus.allCases, id: \.self) { status in
                            Label(status.rawValue, systemImage: status.icon)
                                .tag(status)
                        }
                    }
                    
                    if status == .currentlyReading {
                        HStack {
                            Text("Current Page")
                            Spacer()
                            TextField("0", text: $currentPage)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                    }
                }
                
                // Goodreads Integration Placeholder
                Section {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.secondary)
                        Text("Connect Goodreads")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Coming Soon")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addBook()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !title.isEmpty &&
        !author.isEmpty &&
        (Int(totalPages) ?? 0) > 0
    }
    
    private func addBook() {
        guard let pages = Int(totalPages), pages > 0 else { return }
        let current = Int(currentPage) ?? 0
        
        let book = Book(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            author: author.trimmingCharacters(in: .whitespacesAndNewlines),
            totalPages: pages,
            currentPage: min(current, pages),
            status: status,
            startDate: status == .currentlyReading ? Date() : nil
        )
        
        Task {
            await readingService.addBook(book)
            dismiss()
        }
    }
}

#Preview {
    AddBookSheet()
        .environmentObject(ReadingService())
        .environmentObject(ThemeService())
}
