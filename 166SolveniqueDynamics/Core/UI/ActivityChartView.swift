import Charts
import SwiftUI

struct ActivityChartView: View {
    let data: [(label: String, count: Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(
                title: "Activity",
                subtitle: "Terms viewed in the last 7 days",
                icon: "chart.bar.fill"
            )

            if data.allSatisfy({ $0.count == 0 }) {
                Text("No activity recorded yet. Explore terms to see your chart.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                Chart(data, id: \.label) { item in
                    BarMark(
                        x: .value("Day", item.label),
                        y: .value("Terms", item.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.appPrimary, .appAccent],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(6)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisValueLabel()
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel()
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .frame(height: 170)
            }
        }
        .appCard(elevation: .raised)
    }
}
