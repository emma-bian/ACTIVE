//
//  HomeScreen.swift
//  ACTIVE
//
//  Created by Emma Bian on 2025-12-09.
//

import SwiftUI
import Charts

struct HomeScreen: View {

    @EnvironmentObject var exerciseData: ExerciseData
    @EnvironmentObject var healthKitManager: HealthKitManager

    @State private var formMode: FormMode? = nil

    private var sortedExercises: [Exercise] {
        exerciseData.exercises.sorted { $0.date < $1.date }
    }

    private var groupedByDay: [Date: [Exercise]] {
        Dictionary(grouping: sortedExercises) { exercise in
            Calendar.current.startOfDay(for: exercise.date)
        }
    }

    private var orderedDays: [Date] {
        groupedByDay.keys.sorted()
    }
    
    var body: some View {
        ZStack {
            Color.pale.ignoresSafeArea(.all)

            VStack(alignment: .leading, spacing: 20) {
                titleHeader
                scheduleList
                Spacer()
            }

            addButton
        }
        .onAppear {
        }
        .sheet(item: $formMode) { mode in
            switch mode {
            case .add:
                ExerciseFormSheet()
            case .edit(let exercise):
                ExerciseFormSheet(editingExercise: exercise)
            }
        }
    }

    private var titleHeader: some View {
        Text("Upcoming")
            .font(.custom("Futura", size: 25))
            .foregroundStyle(Color.pale)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.text.opacity(0.8))
            )
            .padding(.top, 15)
            .padding(.leading, 15)
    }

    private var scheduleList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                ForEach(orderedDays, id: \.self) { day in
                    DaySection(
                        day: day,
                        exercises: groupedByDay[day] ?? [],
                        onEdit: { exercise in
                            formMode = .edit(exercise)
                        },
                        onDelete: delete
                    )
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    formMode = .add
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.pale)
                        .frame(width: 56, height: 56)
                        .background(Color.text)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }

    func delete(e: Exercise) {
        if let index = exerciseData.exercises.firstIndex(where: { $0.id == e.id }) {
            exerciseData.exercises.remove(at: index)
        }
    }
}

private enum FormMode: Identifiable {
    case add
    case edit(Exercise)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let exercise): return exercise.id.uuidString
        }
    }
}

private struct DaySection: View {
    let day: Date
    let exercises: [Exercise]
    let onEdit: (Exercise) -> Void
    let onDelete: (Exercise) -> Void

    var body: some View {
        Section {
            VStack(spacing: 0) {
                ForEach(exercises) { exercise in
                    ExerciseRow(exercise: exercise, onEdit: onEdit, onDelete: onDelete)
                }
            }
            .padding(.horizontal)
        } header: {
            ZStack {
                Color(.systemBackground)
                Text(day.formatted(.dateTime.month().day()))
                    .font(.title2)
                    .bold()
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .foregroundStyle(Color.text)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .zIndex(1)
        }
    }
}

private struct ExerciseRow: View {
    @ObservedObject var exercise: Exercise
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var service: AIInsulinAdjustmentService
    let onEdit: (Exercise) -> Void
    let onDelete: (Exercise) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(exercise.name)
                    .bold()
                    .font(.headline)

                Text(exercise.date.formatted(.dateTime.hour().minute()))
                    .padding(.horizontal)

                exerciseTypeIcon

                Spacer()

                Menu {
                    Button("Edit") { onEdit(exercise) }
                    Button("Delete") { onDelete(exercise) }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title)
                }
            }

            HStack {
                Text("Intensity: \(exercise.intensity)")
                Spacer()
                Text("|")
                Spacer()
                Text("Duration: \(exercise.duration) mins")
                Spacer()
                Text("|")
                Spacer()
                Text("Type: \(exercise.type.name)")
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            .padding(.vertical, 5)
            .onAppear {
                if exercise.date.timeIntervalSince(Date()) > 0
                    && exercise.date.timeIntervalSince(Date()) < 7200
                    && (!exercise.aiAdjusted || exercise.wasEdited) {
                    
                    Task {
                        await adjustAI(exercise: exercise)
                    }
                }
            }
            
            Text("Reduce insulin by \(exercise.insulin)% on \(exercise.doseTime.formatted(.dateTime.month().day().hour().minute()))")

            Divider()
                .offset(y: 18)
        }
        .foregroundStyle(Color.text)
        .padding()
    }
    
    private func adjustAI(exercise: Exercise) async {
        do {
            let adjusted = try await service.computeAdjustedInsulin(exercise: exercise, healthKitManager: healthKitManager)
            await MainActor.run {
                exercise.insulin = adjusted
                exercise.aiAdjusted = true
            }
            print("ai adjusted")
            
        } catch {
            print("AI adjustment failed for \(exercise.name): \(error.localizedDescription)")
        }
    }

    @ViewBuilder
    private var exerciseTypeIcon: some View {
        switch exercise.type.name {
        case "Aerobic":
            Image(systemName: "figure.run")
        case "Strength":
            Image(systemName: "figure.strengthtraining.traditional")
        case "Balance":
            Image(systemName: "figure.yoga")
        case "Flexibility":
            Image(systemName: "figure.flexibility")
        default:
            Image(systemName: "figure.run")
        }
    }
}

#Preview {
    HomeScreen()
        .environmentObject(ExerciseData())
        .environmentObject(HealthKitManager())
}
