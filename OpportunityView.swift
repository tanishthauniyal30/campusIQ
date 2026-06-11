import SwiftUI

struct OpportunityView: View {
    @State private var cgpa = ""
    @State private var semester = "4th"
    @State private var skills = ""
    @State private var interests = ""
    @State private var opportunityType = "All"
    @State private var result = ""
    @State private var isLoading = false

    let semesters = ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th"]
    let opportunityTypes = ["All", "Internships", "Hackathons", "Scholarships", "Competitions", "Certifications"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("🏆 Opportunity Matcher")
                            .font(.title2).bold()
                        Text("Find hackathons, internships & scholarships you actually qualify for")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(14)

                    // CGPA + Semester row
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("CGPA", systemImage: "number")
                                .font(.subheadline).bold()
                            TextField("e.g. 8.2", text: $cgpa)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Semester", systemImage: "calendar")
                                .font(.subheadline).bold()
                            Picker("Semester", selection: $semester) {
                                ForEach(semesters, id: \.self) { Text($0) }
                            }
                            .pickerStyle(.menu)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }

                    // Skills
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Your Skills", systemImage: "wrench.and.screwdriver")
                            .font(.headline)
                        TextField("e.g. Python, ML, Web Dev, Swift, DSA", text: $skills, axis: .vertical)
                            .lineLimit(2...3)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }

                    // Interests
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Your Interests", systemImage: "heart")
                            .font(.headline)
                        TextField("e.g. AI, Mobile Apps, Fintech, Gaming, Social Impact", text: $interests, axis: .vertical)
                            .lineLimit(2...3)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }

                    // Type filter
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Looking For", systemImage: "line.3.horizontal.decrease.circle")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(opportunityTypes, id: \.self) { type in
                                    Button(action: { opportunityType = type }) {
                                        Text(type)
                                            .font(.subheadline)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(opportunityType == type ? Color.orange : Color(.systemGray6))
                                            .foregroundColor(opportunityType == type ? .white : .primary)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }
                    }

                    // Find button
                    Button(action: findOpportunities) {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "magnifyingglass.circle.fill")
                            }
                            Text(isLoading ? "Finding opportunities..." : "Find My Opportunities")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(isLoading || skills.isEmpty)

                    // Result
                    if !result.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Matched Opportunities", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundColor(.orange)
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

    func findOpportunities() {
        isLoading = true
        result = ""
        let prompt = """
        You are a career advisor for Indian BTech CSE students.
        
        Student Profile:
        - CGPA: \(cgpa.isEmpty ? "Not specified" : cgpa)
        - Semester: \(semester)
        - Skills: \(skills)
        - Interests: \(interests)
        - Looking for: \(opportunityType)
        
        List 5-6 specific, real opportunities they should apply for RIGHT NOW in 2025:
        - For each: Name, eligibility, deadline (approximate), where to apply, and why it suits them
        - Include mix of: Internshala internships, hackathons (Smart India Hackathon, HackWithInfy, etc.), scholarships (PM Scholarship, etc.), and competitions relevant to their skills
        - Only suggest things they actually qualify for based on their profile
        - Include direct application links or platform names
        
        Use emojis and make it easy to scan. Be specific with real opportunity names.
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
