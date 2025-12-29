import SwiftUI

struct WaterTrackerCard: View {
    let progress: Double
    let amount: Int
    let onAddWater: (Int) -> Void
    
    @State private var showingCustomAmount = false
    @State private var customAmount = ""
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Water Intake")
                    .font(.headline)
                Spacer()
                Text("\(amount)oz / 100oz")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: min(progress, 1.0))
                .tint(progress >= 1.0 ? .green : .blue)
            
            HStack(spacing: 12) {
                ForEach([8, 12, 16, 20], id: \.self) { ounces in
                    Button(action: {
                        onAddWater(ounces)
                    }) {
                        Text("+\(ounces)oz")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
                
                Button(action: {
                    showingCustomAmount = true
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .sheet(isPresented: $showingCustomAmount) {
            NavigationView {
                VStack {
                    TextField("Ounces", text: $customAmount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    Spacer()
                }
                .navigationTitle("Add Water")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingCustomAmount = false
                            customAmount = ""
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            if let amount = Int(customAmount) {
                                onAddWater(amount)
                            }
                            showingCustomAmount = false
                            customAmount = ""
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    WaterTrackerCard(progress: 0.65, amount: 65) { _ in }
}
