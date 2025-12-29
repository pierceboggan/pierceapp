import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var waterTargetString = "100"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goals")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Be more present and enjoy the time I have")
                        Text("• Live a healthy life")
                        Text("• Enjoy the outdoors and Utah more")
                    }
                    .font(.subheadline)
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("KPIs")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Bike:")
                                .bold()
                            Text("Reach 250 FTP")
                        }
                        HStack {
                            Text("Ski:")
                                .bold()
                            Text("Ski every SLC resort, ski 50 days")
                        }
                        HStack {
                            Text("Phone:")
                                .bold()
                            Text("Under 1 hour/day")
                        }
                    }
                    .font(.subheadline)
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Water Tracking")) {
                    HStack {
                        Text("Daily Target")
                        Spacer()
                        TextField("Target", text: $waterTargetString)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("oz")
                            .foregroundColor(.secondary)
                    }
                    .onChange(of: waterTargetString) { newValue in
                        if let value = Int(newValue) {
                            viewModel.updateWaterTarget(value)
                        }
                    }
                }
                
                Section(header: Text("Reading")) {
                    HStack {
                        Text("Goodreads")
                        Spacer()
                        if viewModel.isGoodreadsConnected {
                            Text("Connected")
                                .foregroundColor(.green)
                        } else {
                            Button("Connect") {
                                // TODO: Implement Goodreads OAuth
                            }
                        }
                    }
                }
                
                Section(header: Text("Theme")) {
                    HStack {
                        Text("Current Theme")
                        Spacer()
                        Text(viewModel.currentTheme.name)
                            .foregroundColor(.secondary)
                    }
                    Text("Only 'Default' theme is available in v1")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                waterTargetString = "\(viewModel.waterTarget)"
            }
        }
    }
}

#Preview {
    SettingsView()
}
