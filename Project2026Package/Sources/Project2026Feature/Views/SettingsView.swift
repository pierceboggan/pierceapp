//
//  SettingsView.swift
//  Project2026
//
//  App settings view
//

import SwiftUI

public struct SettingsView: View {
    @EnvironmentObject var themeService: ThemeService
    @EnvironmentObject var waterService: WaterService
    @EnvironmentObject var readingService: ReadingService
    
    @State private var dailyWaterTarget: String = "100"
    @State private var showingResetConfirmation = false
    @State private var showingAbout = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        NavigationStack {
            List {
                // Goals Section
                Section {
                    NavigationLink {
                        GoalsSettingsView()
                    } label: {
                        Label("Goals & KPIs", systemImage: "target")
                    }
                }
                
                // Targets Section
                Section("Daily Targets") {
                    HStack {
                        Label("Water Goal", systemImage: "drop.fill")
                        Spacer()
                        TextField("100", text: $dailyWaterTarget)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .onChange(of: dailyWaterTarget) { _, newValue in
                                if let target = Double(newValue), target > 0 {
                                    Task {
                                        await waterService.updateDailyTarget(target)
                                    }
                                }
                            }
                        Text("oz")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Theme Section
                Section("Appearance") {
                    ForEach(themeService.availableThemes) { appTheme in
                        Button {
                            themeService.selectTheme(appTheme)
                        } label: {
                            HStack {
                                Circle()
                                    .fill(Color(hex: appTheme.primaryHex))
                                    .frame(width: 24, height: 24)
                                
                                Text(appTheme.name)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if themeService.currentTheme.id == appTheme.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(theme.primary)
                                }
                            }
                        }
                    }
                }
                
                // Reading Section
                Section("Reading") {
                    NavigationLink {
                        BooksListView()
                    } label: {
                        Label("My Books", systemImage: "books.vertical.fill")
                    }
                }
                
                // Data Section
                Section("Data") {
                    NavigationLink {
                        ExportSheet()
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }
                
                // About Section
                Section {
                    Button {
                        showingAbout = true
                    } label: {
                        Label("About Project 2026", systemImage: "info.circle")
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .onAppear {
                dailyWaterTarget = String(Int(waterService.dailyTarget))
            }
            .alert("Reset All Data", isPresented: $showingResetConfirmation) {
                Button("Reset", role: .destructive) {
                    // Reset logic would go here
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete all your habits, logs, and history. This action cannot be undone.")
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

// MARK: - Goals Settings View

public struct GoalsSettingsView: View {
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        List {
            Section("High-Level Goals") {
                ForEach(Goal.defaultHighLevelGoals) { goal in
                    HStack {
                        Image(systemName: goal.category.icon)
                            .foregroundColor(theme.primary)
                        Text(goal.title)
                    }
                }
            }
            
            Section("KPIs") {
                ForEach(Goal.defaultKPIs) { goal in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: goal.category.icon)
                                .foregroundColor(theme.primary)
                            Text(goal.title)
                        }
                        
                        if let target = goal.targetValue, let unit = goal.unit {
                            HStack {
                                Text("Target: \(Int(target)) \(unit)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                // Progress would be shown here
                                Text("In Progress")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(theme.warning.opacity(0.1))
                                    .foregroundColor(theme.warning)
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section {
                Text("KPIs are manually tracked in v1. Editing will be available in a future update.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Goals & KPIs")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Books List View

public struct BooksListView: View {
    @EnvironmentObject var readingService: ReadingService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var showingAddBook = false
    @State private var selectedStatus: BookStatus?
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        List {
            // Status Filter
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All",
                            isSelected: selectedStatus == nil,
                            color: theme.primary
                        ) {
                            selectedStatus = nil
                        }
                        
                        ForEach(BookStatus.allCases, id: \.self) { status in
                            FilterChip(
                                title: status.rawValue,
                                isSelected: selectedStatus == status,
                                color: .orange
                            ) {
                                selectedStatus = status
                            }
                        }
                    }
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            // Books
            ForEach(filteredBooks) { book in
                BookRow(book: book)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    Task {
                        await readingService.deleteBook(filteredBooks[index])
                    }
                }
            }
            
            if filteredBooks.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "books.vertical")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No books yet")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("My Books")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddBook = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddBook) {
            AddBookSheet()
        }
    }
    
    private var filteredBooks: [Book] {
        if let status = selectedStatus {
            return readingService.books.filter { $0.status == status }
        }
        return readingService.books
    }
}

// MARK: - Filter Chip

public struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? color : color.opacity(0.1))
                .foregroundColor(isSelected ? .white : color)
                .cornerRadius(16)
        }
    }
}

// MARK: - Book Row

public struct BookRow: View {
    let book: Book
    
    @EnvironmentObject var readingService: ReadingService
    @EnvironmentObject var themeService: ThemeService
    @State private var showingEdit = false
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Cover Placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.orange.opacity(0.2))
                .frame(width: 40, height: 60)
                .overlay {
                    Image(systemName: "book.closed.fill")
                        .foregroundColor(.orange)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(book.author)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: book.status.icon)
                        .font(.caption2)
                    Text(book.status.rawValue)
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if book.status == .currentlyReading {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(book.progressPercentage)%")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("\(book.currentPage)/\(book.totalPages)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingEdit = true
        }
        .sheet(isPresented: $showingEdit) {
            EditBookSheet(book: book)
        }
    }
}

// MARK: - Edit Book Sheet

public struct EditBookSheet: View {
    let book: Book
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var readingService: ReadingService
    @EnvironmentObject var themeService: ThemeService
    
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var totalPages: String = ""
    @State private var currentPage: String = ""
    @State private var status: BookStatus = .currentlyReading
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
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
                
                // Quick Actions
                if status == .currentlyReading {
                    Section("Quick Actions") {
                        Button {
                            Task {
                                await readingService.finishReading(book)
                                dismiss()
                            }
                        } label: {
                            Label("Mark as Finished", systemImage: "checkmark.circle")
                        }
                    }
                }
            }
            .navigationTitle("Edit Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBook()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadBook()
            }
        }
    }
    
    private func loadBook() {
        title = book.title
        author = book.author
        totalPages = String(book.totalPages)
        currentPage = String(book.currentPage)
        status = book.status
    }
    
    private func saveBook() {
        var updatedBook = book
        updatedBook.title = title
        updatedBook.author = author
        updatedBook.totalPages = Int(totalPages) ?? book.totalPages
        updatedBook.currentPage = Int(currentPage) ?? book.currentPage
        updatedBook.status = status
        updatedBook.updatedAt = Date()
        
        if status == .finished && book.status != .finished {
            updatedBook.finishDate = Date()
        }
        
        Task {
            await readingService.updateBook(updatedBook)
            dismiss()
        }
    }
}

// MARK: - About View

public struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeService: ThemeService
    
    private var theme: AppTheme { themeService.currentTheme }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [theme.primary, theme.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Text("2026")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 32)
                    
                    // Title
                    VStack(spacing: 4) {
                        Text("Project 2026")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Your Personal Life OS")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Vision
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vision")
                            .font(.headline)
                        
                        Text("Make 2026 your best year by turning long-term goals into a daily executable system.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(theme.card)
                    .cornerRadius(12)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Features")
                            .font(.headline)
                        
                        FeatureRow(icon: "checkmark.circle.fill", title: "Habit Tracking", color: theme.positive)
                        FeatureRow(icon: "sparkles", title: "Cleaning Rotation", color: .purple)
                        FeatureRow(icon: "drop.fill", title: "Water Tracking", color: .blue)
                        FeatureRow(icon: "book.fill", title: "Reading Progress", color: .orange)
                        FeatureRow(icon: "calendar", title: "History & Analytics", color: theme.primary)
                        FeatureRow(icon: "square.text.square", title: "Home Screen Widget", color: .teal)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(theme.card)
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
            .background(theme.background)
            .navigationTitle("About")
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
}

// MARK: - Feature Row

public struct FeatureRow: View {
    let icon: String
    let title: String
    let color: Color
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(ThemeService())
        .environmentObject(WaterService())
        .environmentObject(ReadingService())
}
