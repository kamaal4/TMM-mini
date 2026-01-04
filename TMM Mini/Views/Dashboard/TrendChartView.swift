//
//  TrendChartView.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI
import Charts

enum ChartDataType {
    case steps
    case calories
}

struct TrendChartView: View {
    let data: [DailyHealthMetrics]
    @State private var selectedDataType: ChartDataType = .steps
    
    var chartData: [(date: Date, value: Double)] {
        data.map { metric in
            let value = selectedDataType == .steps ? Double(metric.steps) : metric.activeCalories
            return (date: metric.date, value: value)
        }
    }
    
    var maxValue: Double {
        chartData.map { $0.value }.max() ?? 1
    }
    
    var body: some View {
        CardView(padding: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Activity Trend")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Last 7 Days")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Segmented Control
                    HStack(spacing: 0) {
                        SegmentedButton(
                            title: "Steps",
                            isSelected: selectedDataType == .steps
                        ) {
                            withAnimation {
                                selectedDataType = .steps
                            }
                        }
                        
                        SegmentedButton(
                            title: "Cals",
                            isSelected: selectedDataType == .calories
                        ) {
                            withAnimation {
                                selectedDataType = .calories
                            }
                        }
                    }
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(8)
                }
                
                // Chart
                Chart {
                    ForEach(Array(chartData.enumerated()), id: \.offset) { index, item in
                        BarMark(
                            x: .value("Day", item.date.weekdaySingle),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(Color.primaryColor.opacity(0.6))
                        .cornerRadius(4)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel()
                            .foregroundStyle(AppTheme.textSecondary)
                            .font(.captionSmall)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(AppTheme.textSecondary)
                            .font(.captionSmall)
                    }
                }
                .frame(height: 120)
            }
        }
    }
}

struct SegmentedButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .medium)
                .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
                .cornerRadius(6)
        }
    }
}

