//
//  ExerciseFormSheet.swift
//  ACTIVE
//
//  Created by Emma Bian on 2026-07-11.
//

import Foundation
import SwiftUI

struct ExerciseFormSheet: View {

    @EnvironmentObject var exerciseData: ExerciseData
    @Environment(\.dismiss) private var dismiss

    private let editingExercise: Exercise?

    @State private var name: String
    @State private var durationText: String
    @State private var intensity: Double
    @State private var typeSelection: String
    @State private var date: Date

    private let typeOptions = ["Aerobic", "Strength", "Flexibility", "Balance"]

    init(editingExercise: Exercise? = nil) {
        self.editingExercise = editingExercise

        _name = State(initialValue: editingExercise?.name ?? "")
        _durationText = State(initialValue: editingExercise.map { String($0.duration) } ?? "")
        _intensity = State(initialValue: Double(editingExercise?.intensity ?? 5))
        _typeSelection = State(initialValue: editingExercise?.type.name ?? "Aerobic")
        _date = State(initialValue: editingExercise?.date ?? Date())
    }

    private var isEditMode: Bool { editingExercise != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)

                    TextField("Duration (mins)", text: $durationText)
                        .keyboardType(.numberPad)

                    HStack {
                        Text("Intensity")
                        Slider(value: $intensity, in: 0...10, step: 1)
                        Text("\(Int(intensity))")
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                    }

                    Picker("Type", selection: $typeSelection) {
                        ForEach(typeOptions, id: \.self) { option in
                            Text(option)
                        }
                    }

                    DatePicker("Date", selection: $date, in: Date()...)
                }
            }
            .navigationTitle(isEditMode ? "Edit exercise" : "Add exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .bold()
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let duration = Int(durationText) ?? 0
        let type = typeFromSelection(typeSelection)

        if let existing = editingExercise {
            updateExercise(id: existing.id, name: name, duration: duration, intensity: intensity, type: type, date: date)
        } else {
            addExercise(name: name, duration: duration, intensity: intensity, type: type, date: date)
        }

        dismiss()
    }

    private func typeFromSelection(_ selection: String) -> Types {
        switch selection {
        case "Aerobic": return .aerobic
        case "Strength": return .strength
        case "Flexibility": return .flexibility
        case "Balance": return .balance
        default: return .aerobic
        }
    }

    private func addExercise(name: String, duration: Int, intensity: Double, type: Types, date: Date) {
        let newExercise = Exercise(
            name: name,
            intensity: Int(intensity), duration: duration,
            type: type,
            date: date
        )
        newExercise.insulin = newExercise.calculateInsulin()
        newExercise.doseTime = newExercise.calculateDoseTime()
        exerciseData.exercises.append(newExercise)
    }

    private func updateExercise(id: UUID, name: String, duration: Int, intensity: Double, type: Types, date: Date) {
        guard let i = exerciseData.exercises.firstIndex(where: { $0.id == id }) else { return }
        exerciseData.exercises[i].name = name
        exerciseData.exercises[i].duration = duration
        exerciseData.exercises[i].intensity = Int(intensity)
        exerciseData.exercises[i].type = type
        exerciseData.exercises[i].date = date
        exerciseData.exercises[i].insulin = exerciseData.exercises[i].calculateInsulin()
        exerciseData.exercises[i].doseTime = exerciseData.exercises[i].calculateDoseTime()
        exerciseData.exercises[i].wasEdited = true
    }
}

#Preview {
    ExerciseFormSheet()
        .environmentObject(ExerciseData())
}
