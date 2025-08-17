//
//  AddFoodView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI
import PhotosUI

// MARK: - 食事追加画面
struct AddFoodView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let selectedDate: Date
    
    @State private var foodName = ""
    @State private var calories: Double = 0
    @State private var selectedMealType: MealType = .breakfast
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var foodPhoto: Data?
    @State private var showingCamera = false
    @State private var isAnalyzingPhoto = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("食事情報") {
                    Picker("食事タイプ", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            Text(mealType.displayName).tag(mealType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    TextField("食べ物の名前", text: $foodName)
                    
                    HStack {
                        Text("カロリー(kcal)")
                        Spacer()
                        TextField("0", value: $calories, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("写真") {
                    HStack {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack {
                                Image(systemName: "photo")
                                Text("ギャラリーから選択")
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera")
                                Text("カメラで撮影")
                            }
                        }
                    }
                    
                    if let photoData = foodPhoto,
                       let uiImage = UIImage(data: photoData) {
                        VStack {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                                .cornerRadius(8)
                            
                            Button("写真からカロリーを推定") {
                                analyzeFoodPhoto()
                            }
                            .buttonStyle(.bordered)
                            .disabled(isAnalyzingPhoto)
                            
                            if isAnalyzingPhoto {
                                ProgressView("解析中...")
                                    .padding()
                            }
                        }
                    }
                }
                
                Section("よく食べる食材") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(commonFoods, id: \.name) { food in
                            Button(action: {
                                foodName = food.name
                                calories = food.calories
                            }) {
                                VStack {
                                    Text(food.name)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                    Text("\(Int(food.calories))kcal")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .navigationTitle("食事追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveFood()
                    }
                    .disabled(foodName.isEmpty || calories <= 0)
                }
            }
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        foodPhoto = data
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView { image in
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        foodPhoto = imageData
                    }
                }
            }
        }
    }
    
    private func analyzeFoodPhoto() {
        guard foodPhoto != nil else { return }
        
        isAnalyzingPhoto = true
        
        // TODO: 実際のAPI呼び出しを行う
        // 例: Clarifai Food Recognition API, Google Vision API など
        
        // 仮の実装（実際のAPIに置き換える）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // ダミーデータ
            foodName = "推定された食べ物"
            calories = 250
            isAnalyzingPhoto = false
        }
    }
    
    private func saveFood() {
        let newFood = FoodEntry(context: viewContext)
        newFood.date = selectedDate
        newFood.foodName = foodName
        newFood.calories = calories
        newFood.mealType = selectedMealType.rawValue
        newFood.photo = foodPhoto
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("保存エラー: \(error)")
        }
    }
}

// MARK: - よく食べる食材データ
struct CommonFood {
    let name: String
    let calories: Double
}

let commonFoods = [
    CommonFood(name: "白米(茶碗1杯)", calories: 252),
    CommonFood(name: "食パン(6枚切り1枚)", calories: 177),
    CommonFood(name: "鶏胸肉(100g)", calories: 191),
    CommonFood(name: "鶏卵(1個)", calories: 91),
    CommonFood(name: "牛乳(200ml)", calories: 134),
    CommonFood(name: "バナナ(1本)", calories: 93),
    CommonFood(name: "りんご(1個)", calories: 138),
    CommonFood(name: "納豆(1パック)", calories: 100),
    CommonFood(name: "豆腐(100g)", calories: 72),
    CommonFood(name: "サラダ(100g)", calories: 20),
    CommonFood(name: "ヨーグルト(100g)", calories: 62),
    CommonFood(name: "アボカド(1個)", calories: 262)
]

// MARK: - カメラビュー
struct CameraView: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
