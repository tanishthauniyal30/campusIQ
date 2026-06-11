import SwiftUI

struct CGPAView: View {
    @State private var cgpa = ""
    @State private var targetCompany = "Google / Microsoft / Amazon"
    @State private var currentSemester = "4th"
    @State private var result = ""
    @State private var isLoading = false

    let companies = [
        "Google / Microsoft / Amazon",
        "Infosys / TCS / Wipro",
        "Flipkart / Swiggy / Zomato",
        "Startups (Series A/B)",
        "Goldman Sachs / JP Morgan",
        "Adobe / Atlassian / Salesforce",
        "FAANG (Top tier)",
        "PSU / Government Jobs"
    ]

    let semesters = ["2nd", "3rd", "4th", "5th", "6th", "7th", "8th"]

    var cgpaColor: Color {
        guard let val = Double(cgpa) else { return .gray }
        if val >= 8.5 { return .green }
        if val >= 7.0 { return .orange }
        return .red
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("📊 CGPA Reality Check")
                            .font(.title2).bold()
                        Text("Find out if your CGPA is competitive and exactly what to do")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(14)

                    // CGPA input
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Your Current CGPA", systemImage: "number.circle")
                            .font(.headline)
                        HStack {
                            TextField("e.g. 7.8", text: $cgpa)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .frame(maxWidth: 150)

                            if !cgpa.isEmpty {
                                Text(cgpa)
                                    .font(.largeTitle).bold()
                                    .foregroundColor(cgpaColor)
                                    .padding(.leading)
                            }
                        }
                    }

                    // Semester
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Current Semester", systemImage: "calendar")
                            .font(.headline)
                        Picker("Semester", selection: $currentSemester) {
                            ForEach(semesters, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Target company
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Target Company / Role", systemImage: "building.2")
                            .font(.headline)
                        Picker("Company", selection: $targetCompany) {
                            ForEach(companies, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }

                    // Analyze button
                    Button(action: analyzeCGPA) {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                            }
                            Text(isLoading ? "Analyzing..." : "Analyze My CGPA")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(isLoading || cgpa.isEmpty)

                    // Result
                    if !result.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("AI Analysis", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundColor(.blue)
                            Text(result)
                                .font(.body)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("CampusIQ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func analyzeCGPA() {
        isLoading = true
        result = ""
        let prompt = """
        You are an honest placement advisor for Indian BTech CSE students.
        
        Student Profile:
        - Current CGPA: \(cgpa)
        - Current Semester: \(currentSemester)
        - Target: \(targetCompany)
        
        Give a realistic assessment:
        1. Is this CGPA competitive for their target? Be honest.
        2. Exact CGPA gap if any (e.g. "You need 0.4 more")
        3. How many semesters left to improve and by how much per semester
        4. Which specific subjects to focus on to improve CGPA
        5. Backup options if CGPA doesn't improve
        
        Be direct and practical. Use emojis. Give specific numbers.
        """

        Task {
            do {
                let response = try await GeminiService.ask(prompt)
                await MainActor.run {
                    result = response
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    result = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}
