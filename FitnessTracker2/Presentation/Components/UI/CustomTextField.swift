//
//  CustomTextField.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI

// MARK: - カスタムテキストフィールド
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let icon: String?
    let unit: String?
    let isRequired: Bool
    let validation: ((String) -> ValidationResult)?
    
    @State private var isEditing: Bool = false
    @State private var validationResult: ValidationResult = .success
    
    init(
        title: String,
        text: Binding<String>,
        placeholder: String = "",
        keyboardType: UIKeyboardType = .default,
        icon: String? = nil,
        unit: String? = nil,
        isRequired: Bool = false,
        validation: ((String) -> ValidationResult)? = nil
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.icon = icon
        self.unit = unit
        self.isRequired = isRequired
        self.validation = validation
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ラベル
            labelView
            
            // テキストフィールド
            textFieldView
            
            // バリデーションエラー
            if !validationResult.isValid {
                errorView
            }
        }
    }
    
    // MARK: - ラベル
    private var labelView: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if isRequired {
                Text("*")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Spacer()
        }
    }
    
    // MARK: - テキストフィールド
    private var textFieldView: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.body)
                .foregroundColor(.primary)
                .onTapGesture {
                    isEditing = true
                }
                .onChange(of: text) { newValue in
                    validateInput(newValue)
                }
                .onSubmit {
                    isEditing = false
                    validateInput(text)
                }
            
            if let unit = unit {
                Text(unit)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor, lineWidth: isEditing ? 2 : 1)
                )
        )
    }
    
    // MARK: - エラー表示
    private var errorView: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(validationResult.errorMessages, id: \.self) { error in
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.caption2)
                    
                    Text(error)
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    // MARK: - 計算プロパティ
    private var borderColor: Color {
        if !validationResult.isValid {
            return .red
        } else if isEditing {
            return .blue
        } else {
            return Color(.systemGray4)
        }
    }
    
    // MARK: - Private Methods
    private func validateInput(_ input: String) {
        if let validation = validation {
            validationResult = validation(input)
        }
    }
}

// MARK: - 数値入力用カスタムテキストフィールド
struct NumericTextField: View {
    let title: String
    @Binding var value: Double
    let placeholder: String
    let unit: String?
    let range: ClosedRange<Double>?
    let decimalPlaces: Int
    let isRequired: Bool
    
    @State private var textValue: String = ""
    
    init(
        title: String,
        value: Binding<Double>,
        placeholder: String = "0",
        unit: String? = nil,
        range: ClosedRange<Double>? = nil,
        decimalPlaces: Int = 1,
        isRequired: Bool = false
    ) {
        self.title = title
        self._value = value
        self.placeholder = placeholder
        self.unit = unit
        self.range = range
        self.decimalPlaces = decimalPlaces
        self.isRequired = isRequired
        self._textValue = State(initialValue: value.wrappedValue > 0 ? String(format: "%.\(decimalPlaces)f", value.wrappedValue) : "")
    }
    
    var body: some View {
        CustomTextField(
            title: title,
            text: $textValue,
            placeholder: placeholder,
            keyboardType: .decimalPad,
            unit: unit,
            isRequired: isRequired,
            validation: validateNumericInput
        )
        .onAppear {
            if value > 0 {
                textValue = String(format: "%.\(decimalPlaces)f", value)
            }
        }
        .onChange(of: textValue) { newValue in
            updateValue(from: newValue)
        }
    }
    
    private func validateNumericInput(_ input: String) -> ValidationResult {
        guard !input.isEmpty else {
            if isRequired {
                return .failure(["この項目は必須です"])
            }
            return .success
        }
        
        guard let doubleValue = Double(input) else {
            return .failure(["数値を入力してください"])
        }
        
        if let range = range, !range.contains(doubleValue) {
            return .failure(["\(range.lowerBound)〜\(range.upperBound)の範囲で入力してください"])
        }
        
        return .success
    }
    
    private func updateValue(from text: String) {
        if let doubleValue = Double(text) {
            value = doubleValue
        } else if text.isEmpty {
            value = 0
        }
    }
}

// MARK: - 整数入力用カスタムテキストフィールド
struct IntegerTextField: View {
    let title: String
    @Binding var value: Int
    let placeholder: String
    let unit: String?
    let range: ClosedRange<Int>?
    let isRequired: Bool
    
    @State private var textValue: String = ""
    
    init(
        title: String,
        value: Binding<Int>,
        placeholder: String = "0",
        unit: String? = nil,
        range: ClosedRange<Int>? = nil,
        isRequired: Bool = false
    ) {
        self.title = title
        self._value = value
        self.placeholder = placeholder
        self.unit = unit
        self.range = range
        self.isRequired = isRequired
        self._textValue = State(initialValue: value.wrappedValue > 0 ? String(value.wrappedValue) : "")
    }
    
    var body: some View {
        CustomTextField(
            title: title,
            text: $textValue,
            placeholder: placeholder,
            keyboardType: .numberPad,
            unit: unit,
            isRequired: isRequired,
            validation: validateIntegerInput
        )
        .onAppear {
            if value > 0 {
                textValue = String(value)
            }
        }
        .onChange(of: textValue) { newValue in
            updateValue(from: newValue)
        }
    }
    
    private func validateIntegerInput(_ input: String) -> ValidationResult {
        guard !input.isEmpty else {
            if isRequired {
                return .failure(["この項目は必須です"])
            }
            return .success
        }
        
        guard let intValue = Int(input) else {
            return .failure(["整数を入力してください"])
        }
        
        if let range = range, !range.contains(intValue) {
            return .failure(["\(range.lowerBound)〜\(range.upperBound)の範囲で入力してください"])
        }
        
        return .success
    }
    
    private func updateValue(from text: String) {
        if let intValue = Int(text) {
            value = intValue
        } else if text.isEmpty {
            value = 0
        }
    }
}

// MARK: - セキュアテキストフィールド
struct SecureTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let isRequired: Bool
    
    @State private var isSecured: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ラベル
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
            }
            
            // セキュアフィールド
            HStack(spacing: 12) {
                Group {
                    if isSecured {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .textFieldStyle(PlainTextFieldStyle())
                .font(.body)
                
                Button(action: {
                    isSecured.toggle()
                }) {
                    Image(systemName: isSecured ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - プレビュー
struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CustomTextField(
                title: "名前",
                text: .constant(""),
                placeholder: "名前を入力",
                icon: "person",
                isRequired: true
            )
            
            NumericTextField(
                title: "体重",
                value: .constant(70.0),
                placeholder: "0.0",
                unit: "kg",
                range: 20...300,
                isRequired: true
            )
            
            IntegerTextField(
                title: "年齢",
                value: .constant(25),
                placeholder: "0",
                unit: "歳",
                range: 10...120,
                isRequired: true
            )
            
            SecureTextField(
                title: "パスワード",
                text: .constant(""),
                placeholder: "パスワードを入力",
                isRequired: true
            )
        }
        .padding()
    }
}
