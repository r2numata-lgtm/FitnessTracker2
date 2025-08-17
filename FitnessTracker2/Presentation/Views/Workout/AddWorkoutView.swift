//
//  AddWorkoutView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI
import CoreData

// MARK: - 筋トレ追加画面（種目選択）
struct AddWorkoutView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let selectedDate: Date
    
    @State private var selectedExerciseCategory = "胸"
    @State private var showingAddExercise = false
    @State private var showingExerciseDetail = false
    @State private var selectedExercise = ""
    
    let exerciseCategories = ["胸", "背中", "肩", "腕", "脚", "腹筋", "有酸素"]
    
    @State private var exercisesByCategory: [String: [String]] = [
        "胸": ["ベンチプレス", "インクラインベンチプレス", "ダンベルフライ", "腕立て伏せ"],
        "背中": ["デッドリフト", "懸垂", "ラットプルダウン", "ベントオーバーロー"],
        "肩": ["ショルダープレス", "サイドレイズ", "リアレイズ", "アップライトロー"],
        "腕": ["バーベルカール", "トライセプスエクステンション", "ハンマーカール", "ディップス"],
        "脚": ["スクワット", "レッグプレス", "レッグカール", "カーフレイズ"],
        "腹筋": ["クランチ", "プランク", "レッグレイズ", "バイシクルクランチ"],
        "有酸素": ["ランニング", "サイクリング", "ウォーキング", "エリプティカル"]
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // カテゴリ選択
                Picker("カテゴリ", selection: $selectedExerciseCategory) {
                    ForEach(exerciseCategories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 種目一覧
                List {
                    ForEach(exercisesByCategory[selectedExerciseCategory] ?? [], id: \.self) { exercise in
                        Button(action: {
                            selectedExercise = exercise
                            showingExerciseDetail = true
                        }) {
                            HStack {
                                Text(exercise)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    // 種目追加ボタン
                    Button(action: {
                        showingAddExercise = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("新しい種目を追加")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("種目選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView(
                    category: selectedExerciseCategory,
                    onExerciseAdded: { newExercise in
                        addExerciseToCategory(newExercise, to: selectedExerciseCategory)
                    }
                )
            }
            .sheet(isPresented: $showingExerciseDetail) {
                ExerciseDetailView(
                    exerciseName: selectedExercise,
                    selectedDate: selectedDate,
                    isEditMode: false
                )
                .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    private func addExerciseToCategory(_ exercise: String, to category: String) {
        if exercisesByCategory[category] != nil {
            exercisesByCategory[category]?.append(exercise)
        } else {
            exercisesByCategory[category] = [exercise]
        }
    }
}

// MARK: - 運動種目追加画面
struct AddExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let category: String
    let onExerciseAdded: (String) -> Void
    
    @State private var exerciseName = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("\(category)の新しい種目を追加")) {
                    TextField("運動種目名を入力", text: $exerciseName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("例: \(getExampleExercise())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Text("・運動種目名は分かりやすい名前にしてください")
                    Text("・既存の種目と重複しないようにしてください")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .navigationTitle("種目追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        addExercise()
                    }
                    .disabled(exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("エラー", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func getExampleExercise() -> String {
        let examples: [String: String] = [
            "胸": "インクラインダンベルプレス",
            "背中": "ワンハンドロー",
            "肩": "フロントレイズ",
            "腕": "プリーチャーカール",
            "脚": "ブルガリアンスクワット",
            "腹筋": "ロシアンツイスト",
            "有酸素": "エアロバイク"
        ]
        return examples[category] ?? "新しい運動"
    }
    
    private func addExercise() {
        let trimmedName = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // バリデーション
        if trimmedName.isEmpty {
            alertMessage = "運動種目名を入力してください"
            showingAlert = true
            return
        }
        
        if trimmedName.count > 30 {
            alertMessage = "運動種目名は30文字以内で入力してください"
            showingAlert = true
            return
        }
        
        // 成功時の処理
        onExerciseAdded(trimmedName)
        presentationMode.wrappedValue.dismiss()
    }
}
