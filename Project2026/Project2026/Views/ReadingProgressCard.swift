import SwiftUI

struct ReadingProgressCard: View {
    let books: [Book]
    let onLogReading: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Currently Reading")
                .font(.headline)
            
            ForEach(books) { book in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(book.author)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let progress = book.progress {
                            HStack {
                                ProgressView(value: progress.percentageComplete(totalPages: book.totalPages) / 100)
                                    .tint(.blue)
                                Text("\(Int(progress.percentageComplete(totalPages: book.totalPages)))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: onLogReading) {
                        Text("Log")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    ReadingProgressCard(
        books: [
            Book(
                title: "Atomic Habits",
                author: "James Clear",
                totalPages: 320,
                isCurrentlyReading: true,
                progress: ReadingProgress(pagesRead: 112)
            )
        ],
        onLogReading: {}
    )
}
