//
//  AddBodyCompositionView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI

// MARK: - 体組成追加画面
struct AddBodyCompositionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var healthKitManager: HealthKitManager
    
    @State private var height: Double = 170
    @State private var weight: Double = 70
    @State private var bodyFatPercentage: Double = 0
    @State private var age: Int = 30
    @State private var gender: Gender = .male
    @State private var activityLevel: ActivityLevel = .moderate
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本情報") {
                    HStack {
                        Text("身長(cm)")
                        Spacer()
                        TextField("170", value: $height, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("体重(kg)")
                        Spacer()
                        TextField("70", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("年齢")
                        Spacer()
                        TextField("30", value: $age, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("性別", selection: $gender) {
                        Text("男性").tag(Gender.male)
                        Text("女性").tag(Gender.female)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("詳細情報") {
                    HStack {
                        Text("体脂肪率(%)")
                        Spacer()
                        TextField("0", value: $bodyFatPercentage, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("活動レベル", selection: $activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                }
                
                Section("計算結果") {
                    HStack {
                        Text("BMI")
                        Spacer()
                        Text(String(format: "%.1f", calculateBMI()))
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("基礎代謝量")
                        Spacer()
                        Text("\(Int(calculateBMR()))kcal/日")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("推定消費カロリー")
                        Spacer()
                        Text("\(Int(calculateTDEE()))kcal/日")
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("体組成記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveBodyComposition()
                    }
                }
            }
        }
    }
    
    private func calculateBMI() -> Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    private func calculateBMR() -> Double {
        // Harris-Benedict式
        switch gender {
        case .male:
            return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        case .female:
            return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        }
    }
    
    private func calculateTDEE() -> Double {
        return calculateBMR() * activityLevel.multiplier
    }
    
    private func saveBodyComposition() {
        let newComposition = BodyComposition(context: viewContext)
        newComposition.date = Date()
        newComposition.height = height
        newComposition.weight = weight
        newComposition.bodyFatPercentage = bodyFatPercentage
        newComposition.basalMetabolicRate = calculateBMR()
        
        do {
            try viewContext.save()
            
            // HealthKitに体重データを保存
            healthKitManager.saveWeightToHealthKit(weight)
            
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("保存エラー: \(error)")
        }
    }
