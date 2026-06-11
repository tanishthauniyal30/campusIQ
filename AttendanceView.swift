import SwiftUI

struct AttendanceView: View {
    @State private var totalClasses = ""
    @State private var attendedClasses = ""
    @State private var remainingWeeks = ""
    @State private var classesPerWeek = ""
    @State private var minRequired = 75.0
    @State private var showResult = false

    var currentPercentage: Double {
        guard let total = Double(totalClasses), let attended = Double(attendedClasses), total > 0 else { return 0 }
        return (attended / total) * 100
    }

    var safeToMiss: Int {
        guard let total = Double(totalClasses),
              let attended = Double(attendedClasses),
              let weeks = Double(remainingWeeks),
              let perWeek = Double(classesPerWeek) else { return 0 }

        let futureClasses = weeks * perWeek
        let finalTotal = total + futureClasses
        let minAttend = (minRequired / 100) * finalTotal
        let canMiss = (attended + futureClasses) - minAttend
        return max(0, Int(floor(canMiss)))
    }

    var attendanceStatus: (String, Color) {
        if currentPercentage >= 85 { return ("✅ Safe", .green) }
        if currentPercentage >= 75 { return ("⚠️ Borderline", .orange) }
        return ("🚨 Danger Zone", .red)
    }

    var classesToRecover: Int {
        guard let total = Double(totalClasses),
              let attended = Double(attendedClasses),
              total > 0, currentPercentage < minRequired else { return 0 }
        let needed = (minRequired / 100) * total
        return max(0, Int(ceil(needed - attended)))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("📅 Attendance Calculator")
                            .font(.title2).bold()
                        Text("Know exactly how many classes you can safely skip")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(14)

                    // Current attendance
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Total Classes", systemImage: "sum")
                                .font(.subheadline).bold()
                            TextField("e.g. 60", text: $totalClasses)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Classes Attended", systemImage: "checkmark.circle")
                                .font(.subheadline).bold()
                            TextField("e.g. 48", text: $attendedClasses)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }

                    // Remaining classes
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Weeks Remaining", systemImage: "calendar")
                                .font(.subheadline).bold()
                            TextField("e.g. 4", text: $remainingWeeks)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Classes/Week", systemImage: "repeat")
                                .font(.subheadline).bold()
                            TextField("e.g. 5", text: $classesPerWeek)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }

                    // Minimum required slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Minimum Required", systemImage: "percent")
                                .font(.headline)
                            Spacer()
                            Text("\(Int(minRequired))%")
                                .font(.headline).bold()
                                .foregroundColor(.green)
                        }
                        Slider(value: $minRequired, in: 65...85, step: 5)
                            .accentColor(.green)
                        HStack {
                            Text("65%").font(.caption).foregroundColor(.secondary)
                            Spacer()
                            Text("75% (Standard)").font(.caption).foregroundColor(.secondary)
                            Spacer()
                            Text("85%").font(.caption).foregroundColor(.secondary)
                        }
                    }

                    // Calculate button
                    Button(action: { showResult = true }) {
                        HStack {
                            Image(systemName: "function")
                            Text("Calculate").bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(totalClasses.isEmpty || attendedClasses.isEmpty)

                    // Result cards
                    if showResult && !totalClasses.isEmpty && !attendedClasses.isEmpty {
                        VStack(spacing: 14) {
                            // Current status card
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Current Attendance")
                                        .font(.subheadline).foregroundColor(.secondary)
                                    Text("\(String(format: "%.1f", currentPercentage))%")
                                        .font(.largeTitle).bold()
                                        .foregroundColor(attendanceStatus.1)
                                }
                                Spacer()
                                Text(attendanceStatus.0)
                                    .font(.title2)
                                    .padding()
                                    .background(attendanceStatus.1.opacity(0.15))
                                    .cornerRadius(10)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(14)

                            if currentPercentage >= minRequired {
                                // Safe to miss
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("You Can Still Miss")
                                            .font(.subheadline).foregroundColor(.secondary)
                                        Text("\(safeToMiss) classes")
                                            .font(.largeTitle).bold()
                                            .foregroundColor(.blue)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(14)
                            } else {
                                // Need to recover
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Must Attend Next")
                                            .font(.subheadline).foregroundColor(.secondary)
                                        Text("\(classesToRecover) classes")
                                            .font(.largeTitle).bold()
                                            .foregroundColor(.red)
                                        Text("to reach \(Int(minRequired))%")
                                            .font(.caption).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.red)
                                }
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(14)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("CampusIQ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
