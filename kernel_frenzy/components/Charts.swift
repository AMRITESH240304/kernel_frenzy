import SwiftUI
import Charts

struct GlassChartCard: View {
    let title: String
    let dataPoints: [(Date, Double)]
    let gradientColors: [Color]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(title): \(dataPoints.last?.1 ?? 0, specifier: "%.2f")%")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 10)
                .padding(.horizontal)

            Chart(dataPoints, id: \.0) { (timestamp, value) in
                LineMark(
                    x: .value("Time", timestamp),
                    y: .value("\(title) Usage (%)", value)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .shadow(radius: 2)
            }
            .frame(height: 150)
            .padding(.horizontal)
        }
        .padding(.bottom)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}
