//
//  ChartScreen.swift
//  ACTIVE
//
//  Created by Emma Bian on 2026-07-11.
//

import SwiftUI
import Charts

struct ChartScreen: View {
 
    @EnvironmentObject var exerciseData: ExerciseData
    @EnvironmentObject var healthKitManager: HealthKitManager
 
    var body: some View {
        ZStack {
            Color.pale.ignoresSafeArea(.all)
 
            VStack(alignment: .leading, spacing: 20) {
                Text("Trends")
                    .font(.custom("Futura", size: 25))
                    .foregroundStyle(Color.pale)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.text.opacity(0.8))
                    )
                    .padding(.top, 15)
                    .padding(.leading, 15)
 
                ScrollView {
                    VStack(spacing: 16) {
                        VitalChartCard(
                            title: "Glucose",
                            unitLabel: "mg/dL",
                            readings: healthKitManager.glucoseReadings,
                            lineColor: Color.text,
                            yAxisLabel: "mg/dL"
                        )
 
                        VitalChartCard(
                            title: "Heart Rate",
                            unitLabel: "bpm",
                            readings: healthKitManager.heartRateReadings,
                            lineColor: Color.text,
                            yAxisLabel: "bpm"
                        )
 
                        VitalChartCard(
                            title: "Oxygen Saturation",
                            unitLabel: "%",
                            readings: healthKitManager.oxygenSaturationReadings,
                            lineColor: Color.text,
                            yAxisLabel: "% SpO2"
                        )
                    }
                    .padding(.horizontal)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
 
 
private struct VitalChartCard: View {
    let title: String
    let unitLabel: String
    let readings: [VitalReading]
    let lineColor: Color
    let yAxisLabel: String
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.text)
 
                Spacer()
 
                if let latest = readings.last {
                    Text("\(formatted(latest.value)) \(unitLabel)")
                        .font(.subheadline)
                        .foregroundStyle(Color.text.opacity(0.7))
                }
            }
 
            if readings.isEmpty {
                Text("No data yet")
                    .font(.footnote)
                    .foregroundStyle(Color.text.opacity(0.6))
                    .frame(maxWidth: .infinity, minHeight: 160, alignment: .center)
            } else {
                HStack (spacing: 4){
                    Text(yAxisLabel)
                        .font(.footnote)
                        .foregroundStyle(Color.text.opacity(0.6))
                        .fixedSize()
                        .rotationEffect(.degrees(-90))
                        .frame(width: 16)
                    
                    VStack (spacing: 4) {
                        Chart(readings) { reading in
                            LineMark(
                                x: .value("Time", reading.date),
                                y: .value(title, reading.value)
                            )
                            .foregroundStyle(lineColor)
                            .interpolationMethod(.catmullRom)
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel(format: .dateTime.hour())
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel()
                            }
                        }
                        .frame(height: 180)
                        
                        Text("Time")
                            .font(.footnote)
                            .foregroundStyle(Color.text.opacity(0.6))
                            .fixedSize()
                            .frame(width: 16)
                    }
                }
            }
        }
        .padding()
        .background(Color.myGray.opacity(0.2))
        .cornerRadius(10)
    }
 
    private func formatted(_ value: Double) -> String {
        String(Int(value.rounded()))
    }
}

#Preview {
    ChartScreen()
        .environmentObject(ExerciseData())
        .environmentObject(HealthKitManager())
}
