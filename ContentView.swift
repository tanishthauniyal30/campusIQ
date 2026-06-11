import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ElectiveView()
                .tabItem {
                    Label("Electives", systemImage: "books.vertical.fill")
                }

            CGPAView()
                .tabItem {
                    Label("CGPA", systemImage: "chart.bar.fill")
                }

            AttendanceView()
                .tabItem {
                    Label("Attendance", systemImage: "calendar.badge.checkmark")
                }

            OpportunityView()
                .tabItem {
                    Label("Opportunities", systemImage: "star.fill")
                }
        }
        .accentColor(.indigo)
    }
}
