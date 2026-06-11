import SwiftUI

struct ElectiveView: View {
    @State private var semester = "3rd"
    @State private var careerGoal = "Software Engineer (SDE)"
    @State private var strengths = ""
    @State private var weaknesses = ""
    @State private var result = ""
    @State private var isLoading = false

    let semesters = ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th"]
    let careerGoals = [
        "Software Engineer (SDE)",
        "Data Scientist / ML Engineer",
        "Product Manager",
        "Startup / Entrepreneurship",
        "Higher Studies (MS/MBA)",
        "DevOps / Cloud Engineer",
        "iOS / Mobile Developer"
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header card
                    VStack(alignment: .leading, spacing: 6) {
                        Text("🎯 Elective Advisor")
                            .font(.title2).bold()
                        Text("Get AI-powered elective recommendations based on your goals")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.indigo.opacity(0.1))
                    .cornerRadius(14)

                    // Semester picker
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Current Semester", systemImage: "graduationcap")
                            .font(.headline)
                        Picker("Semester", selection: $semester) {
                            ForEach(semesters, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Career goal picker
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Career Goal", systemImage: "target")
                            .font(.headline)
                        Picker("Career Goal", selection: $careerGoal) {
                            ForEach(careerGoals, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }

                    // Strengths
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Subjects You Enjoy / Are Good At", systemImage: "hand.thumbsup")
                            .font(.headline)
                        TextField("e.g. Maths, Programming, Algorithms", text: $strengths, axis: .vertical)
                            .lineLimit(2...4)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }

                    // Weaknesses
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Subjects You Struggle With", systemImage: "hand.thumbsdown")
                            .font(.headline)
                        TextField("e.g. Theory, Hardware, Networks", text: $weaknesses, axis: .vertical)
                            .lineLimit(2...4)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }

                    // Get recommendations button
                    Button(action: getRecommendations) {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "wand.and.stars")
                            }
                            Text(isLoading ? "Analyzing..." : "Get Elective Recommendations")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(isLoading || strengths.isEmpty)

                    // Result
                    if !result.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("AI Recommendation", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundColor(.indigo)
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

    func getRecommendations() {
        isLoading = true
        result = ""
        let prompt = """
        You are an expert college academic advisor for Indian BTech CSE students.
        
        Student Profile:
        - Current Semester: \(semester)
        - Career Goal: \(careerGoal)
        - Strong Subjects: \(strengths)
        - Weak Subjects: \(weaknesses.isEmpty ? "Not specified" : weaknesses)
        
        Give 3-4 specific elective recommendations with:
        1. Elective name
        2. Why it suits their career goal
        3. What skills it builds
        4. One elective to AVOID and why
        
        Keep it concise, practical, and specific to Indian BTech curriculum. Use emojis for readability.
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
