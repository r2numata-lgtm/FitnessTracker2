//
//  ExerciseDetailView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI
import CoreData

// MARK: - 種目詳細記録画面
struct ExerciseDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let exerciseName: String
    let selectedDate: Date
    let isEditMode: Bool
    
    @State private var sets: [ExerciseSet] = [ExerciseSet()]
    @State private var showingDeleteAlert = false
    
    // 編集モード用
    @FetchRequest private var existingWorkouts: FetchedResults<WorkoutEntry>
    
    init(exerciseName: String, selectedDate: Date, isEditMode: Bool = false) {
        self.exerciseName = exerciseName
        self.selectedDate = selectedDate
        self.isEditMode = isEditMode
        
        // 編集モードの場合、その日のその種目の記録を取得
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        self._existingWorkouts = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: true)],
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "exerciseName == %@", exerciseName),
                NSPredicate(format: "date >= %@", startOfDay as NSDate),
                NSPredicate(format: "date < %@", endOfDay as NSDate)
            ])
        )
    }
    
    private func loadExistingSets() {
        if !existingWorkouts.isEmpty {
            sets = existingWorkouts.map { workout in
                ExerciseSet(
                    weight: workout.weight,
                    reps: Int(workout.reps),
                    memo: workout.memo ?? ""
                )
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("セット記録")) {
                    ForEach(sets.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("セット \(index + 1)")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("重量 (kg)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    TextField("0", value: $sets[index].weight, format: .number)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("回数")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    TextField("0", value: $sets[index].reps, format: .number)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                Text("メモ")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("メモを入力（任意）", text: $sets[index].memo)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            if sets.count > 1 {
                                Button(action: {
                                    sets.remove(at: index)
                                }) {
                                    HStack {
                                        Image(systemName: "minus.circle.fill")
                                        Text("このセットを削除")
                                    }
                                    .foregroundColor(.red)
                                    .font(.caption)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        sets.append(ExerciseSet())
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("セットを追加")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("消費カロリー")) {
                    HStack {
                        Text("合計消費カロリー")
                        Spacer()
                        Text("\(calculateTotalCalories())kcal")
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                    }
                }
                
                if isEditMode {
                    Section {
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("この種目を削除")
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle(exerciseName)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if isEditMode {
                    loadExistingSets()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "更新" : "保存") {
                        saveWorkout()
                    }
                    .disabled(sets.isEmpty || sets.allSatisfy { $0.weight == 0 && $0.reps == 0 })
                }
            }
削除の確認", isPresented: $showingDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive
