//
//  FoodView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI
import CoreData
import PhotosUI

struct FoodView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddFood = false
    @State private var selectedDate = Date()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.date, ascending: false)],
        animation: .default)
    private var foods: FetchedResults<FoodEntry>
    
    var body: some View {
        NavigationView {
            VStack {
                // 日付選択
                DatePicker("日付", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding()
                
                // 食事カテゴリ別表示
                List {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        Section(mealType.displayName) {
                            ForEach(filteredFoods(for: mealType), id: \.self) { food in
                                FoodRowView(food: food)
                            }
                            .onDelete { offsets in
                                deleteFood(offsets: offsets, mealType: mealType)
                            }
                        }
                    }
                }
                
                // 合計カロリー表示
                TotalCaloriesView(foods: filteredFoodsForDay)
            }
            .navigationTitle("食事記録")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddFood = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFood) {
                AddFoodView(selectedDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    private var filteredFoodsForDay: [FoodEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return foods.filter { food in
            food.date >= startOfDay && food.date < endOfDay
        }
    }
    
    private func filteredFoods(for mealType: MealType) -> [FoodEntry] {
        return filteredFoodsForDay.filter { food in
            food.mealType == mealType.rawValue
        }
    }
    
    private func deleteFood(offsets: IndexSet, mealType: MealType) {
        withAnimation {
            let foodsToDelete = filteredFoods(for: mealType)
            offsets.map { foodsToDelete[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("削除エラー: \(error)")
            }
        }
    }
}

// MARK: - 食事行表示
struct FoodRowView: View {
    let food: FoodEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(food.foodName ?? "")
                    .font(.headline)
                
                Text("\(Int(food.calories))kcal")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            // 写真がある場合は表示
            if let photoData = food.photo,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - 合計カロリー表示
struct TotalCaloriesView: View {
    let foods: [FoodEntry]
    
    private var totalCalories: Double {
        foods.reduce(0) { $0 + $1.calories }
    }
    
    var body: some View {
        HStack {
            Text("合計摂取カロリー")
                .font(.headline)
            
            Spacer()
            
            Text("\(Int(totalCalories))kcal")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct FoodView_Previews: PreviewProvider {
    static var previews: some View {
        FoodView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
