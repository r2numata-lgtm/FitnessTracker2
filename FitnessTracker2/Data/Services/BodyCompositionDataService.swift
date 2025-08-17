//
//  BodyCompositionDataService.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import CoreData
import Foundation

class BodyCompositionDataService: DataService<BodyComposition> {
    
    // MARK: - Body Composition Specific Methods
    func fetchLatestEntry() -> BodyComposition? {
        let sortDescriptors = [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: false)]
        return fetch(sortDescriptors: sortDescriptors).first
    }
    
    func fetchEntriesForPeriod(_ period: TimePeriod) -> [BodyComposition] {
        let range = period.dateRange
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@",
                                   range.start as NSDate,
                                   range.end as NSDate)
        let sortDescriptors = [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: true)]
        
        return fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }
    
    func fetchWeightHistory(limit: Int = 30) -> [BodyComposition] {
        let sortDescriptors = [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: false)]
        let results = fetch(sortDescriptors: sortDescriptors)
        return Array(results.prefix(limit))
    }
    
    func fetchEntryForDate(_ date: Date) -> BodyComposition? {
        let predicate = DateRangeService.createDatePredicate(for: date)
        return fetchFirst(predicate: predicate)
    }
    
    // MARK: - Statistics and Analysis
    func getWeightTrend(days: Int = 30) -> WeightTrend {
        let entries = fetchWeightHistory(limit: days)
        guard entries.count >= 2 else {
            return WeightTrend(direction: .stable, change: 0, period: days)
        }
        
        let latest = entries.first!.weight
        let oldest = entries.last!.weight
        let change = latest - oldest
        
        let direction: WeightTrend.Direction
        if abs(change) < 0.5 {
            direction = .stable
        } else if change > 0 {
            direction = .increasing
        } else {
            direction = .decreasing
        }
        
        return WeightTrend(direction: direction, change: change, period: days)
    }
    
    func getBMITrend(days: Int = 30) -> BMITrend {
        let entries = fetchWeightHistory(limit: days)
        guard entries.count >= 2 else {
            return BMITrend(current: 0, change: 0, category: .normal)
        }
        
        let latest = entries.first!
        let oldest = entries.last!
        
        let currentBMI = latest.bmi
        let oldBMI = oldest.bmi
        let change = currentBMI - oldBMI
        
        return BMITrend(
            current: currentBMI,
            change: change,
            category: latest.bmiCategory
        )
    }
    
    func getBodyFatTrend(days: Int = 30) -> BodyFatTrend? {
        let entries = fetchWeightHistory(limit: days).filter { $0.bodyFatPercentage > 0 }
        guard entries.count >= 2 else { return nil }
        
        let latest = entries.first!.bodyFatPercentage
        let oldest = entries.last!.bodyFatPercentage
        let change = latest - oldest
        
        return BodyFatTrend(current: latest, change: change, period: days)
    }
    
    func getProgressSummary() -> ProgressSummary? {
        guard let latest = fetchLatestEntry() else { return nil }
        
        let weightTrend = getWeightTrend()
        let bmiTrend = getBMITrend()
        let bodyFatTrend = getBodyFatTrend()
        
        return ProgressSummary(
            currentEntry: latest,
            weightTrend: weightTrend,
            bmiTrend: bmiTrend,
            bodyFatTrend: bodyFatTrend
        )
    }
    
    func getMonthlyAverages() -> [MonthlyAverage] {
        var monthlyData: [MonthlyAverage] = []
        let calendar = Calendar.current
        
        for i in 0..<12 { // 過去12ヶ月
            let monthDate = calendar.date(byAdding: .month, value: -i, to: Date()) ?? Date()
            let entries = fetchEntriesForPeriod(.month)
            
            guard !entries.isEmpty else { continue }
            
            let avgWeight = entries.reduce(0) { $0 + $1.weight } / Double(entries.count)
            let avgBMI = entries.reduce(0) { $0 + $1.bmi } / Double(entries.count)
            let avgBodyFat = entries.filter { $0.bodyFatPercentage > 0 }
                .reduce(0) { $0 + $1.bodyFatPercentage } / Double(entries.count)
            
            monthlyData.append(MonthlyAverage(
                month: monthDate,
                averageWeight: avgWeight,
                averageBMI: avgBMI,
                averageBodyFat: avgBodyFat > 0 ? avgBodyFat : nil,
                entryCount: entries.count
            ))
        }
        
        return monthlyData.reversed()
    }
    
    // MARK: - Goals and Targets
    func calculateGoalProgress(targetWeight: Double) -> GoalProgress? {
        guard let current = fetchLatestEntry() else { return nil }
        
        let difference = targetWeight - current.weight
        let progress = abs(difference)
        
        let status: GoalProgress.Status
        if abs(difference) <= 1.0 {
            status = .achieved
        } else if (difference > 0 && getWeightTrend().direction == .increasing) ||
                  (difference < 0 && getWeightTrend().direction == .decreasing) {
            status = .onTrack
        } else {
            status = .needsAttention
        }
        
        return GoalProgress(
            currentWeight: current.weight,
            targetWeight: targetWeight,
            difference: difference,
            status: status
        )
    }
    
    // MARK: - Create and Update
    func createBodyComposition(from dto: BodyCompositionDTO) throws -> BodyComposition {
        let composition = create()
        
        composition.date = dto.date
        composition.height = dto.height
        composition.weight = dto.weight
        composition.bodyFatPercentage = dto.bodyFatPercentage
        composition.basalMetabolicRate = dto.basalMetabolicRate
        
        try save()
        
        // HealthKitに体重データを保存
        if let healthKitManager = HealthKitManager.shared {
            healthKitManager.saveWeightToHealthKit(dto.weight, date: dto.date)
        }
        
        return composition
    }
    
    func updateBodyComposition(_ composition: BodyComposition, with dto: BodyCompositionDTO) throws {
        composition.date = dto.date
        composition.height = dto.height
        composition.weight = dto.weight
        composition.bodyFatPercentage = dto.bodyFatPercentage
        composition.basalMetabolicRate = dto.basalMetabolicRate
        
        try save()
    }
    
    // MARK: - Data Export
    func exportData(format: ExportFormat) -> Data? {
        let entries = fetch(sortDescriptors: [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: true)])
        
        switch format {
        case .csv:
            return exportToCSV(entries)
        case .json:
            return exportToJSON(entries)
        }
    }
    
    private func exportToCSV(_ entries: [BodyComposition]) -> Data? {
        var csvContent = "日付,身長(cm),体重(kg),体脂肪率(%),基礎代謝(kcal),BMI\n"
        
        for entry in entries {
            let line = "\(entry.formattedDate),\(entry.height),\(entry.weight),\(entry.bodyFatPercentage),\(entry.basalMetabolicRate),\(entry.bmi.formatted(decimalPlaces: 1))\n"
            csvContent += line
        }
        
        return csvContent.data(using: .utf8)
    }
    
    private func exportToJSON(_ entries: [BodyComposition]) -> Data? {
        let jsonEntries = entries.map { entry in
            return [
                "date": entry.date.timeIntervalSince1970,
                "height": entry.height,
                "weight": entry.weight,
                "bodyFatPercentage": entry.bodyFatPercentage,
                "basalMetabolicRate": entry.basalMetabolicRate,
                "bmi": entry.bmi
            ]
        }
        
        return try? JSONSerialization.data(withJSONObject: jsonEntries, options: .prettyPrinted)
    }
}

// MARK: - Supporting Types
struct WeightTrend {
    enum Direction {
        case increasing, decreasing, stable
        
        var description: String {
            switch self {
            case .increasing: return "増加傾向"
            case .decreasing: return "減少傾向"
            case .stable: return "安定"
            }
        }
        
        var color: UIColor {
            switch self {
            case .increasing: return .systemRed
            case .decreasing: return .systemBlue
            case .stable: return .systemGreen
            }
        }
    }
    
    let direction: Direction
    let change: Double
    let period: Int
    
    var formattedChange: String {
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(change.formatted(decimalPlaces: 1))kg"
    }
}

struct BMITrend {
    let current: Double
    let change: Double
    let category: BMICategory
    
    var formattedCurrent: String {
        return current.formatted(decimalPlaces: 1)
    }
    
    var formattedChange: String {
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(change.formatted(decimalPlaces: 1))"
    }
}

struct BodyFatTrend {
    let current: Double
    let change: Double
    let period: Int
    
    var formattedCurrent: String {
        return current.formatted(decimalPlaces: 1) + "%"
    }
    
    var formattedChange: String {
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(change.formatted(decimalPlaces: 1))%"
    }
}

struct ProgressSummary {
    let currentEntry: BodyComposition
    let weightTrend: WeightTrend
    let bmiTrend: BMITrend
    let bodyFatTrend: BodyFatTrend?
}

struct MonthlyAverage {
    let month: Date
    let averageWeight: Double
    let averageBMI: Double
    let averageBodyFat: Double?
    let entryCount: Int
    
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: month)
    }
}

struct GoalProgress {
    enum Status {
        case achieved, onTrack, needsAttention
        
        var description: String {
            switch self {
            case .achieved: return "目標達成"
            case .onTrack: return "順調"
            case .needsAttention: return "要注意"
            }
        }
        
        var color: UIColor {
            switch self {
            case .achieved: return .systemGreen
            case .onTrack: return .systemBlue
            case .needsAttention: return .systemOrange
            }
        }
    }
    
    let currentWeight: Double
    let targetWeight: Double
    let difference: Double
    let status: Status
    
    var formattedDifference: String {
        let abs = abs(difference)
        let direction = difference > 0 ? "あと" : "目標より"
        return "\(direction)\(abs.formatted(decimalPlaces: 1))kg"
    }
}

enum ExportFormat {
    case csv, json
}
