//
//  BodyCompositionViewModel.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import Foundation
import SwiftUI
import CoreData
import Combine

// MARK: - 体組成ビューモデル
@MainActor
class BodyCompositionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var height: Double = 170.0
    @Published var weight: Double = 70.0
    @Published var bodyFatPercentage: Double = 0.0
    @Published var age: Int = 30
    @Published var gender: Gender = .male
    @Published var activityLevel: ActivityLevel = .moderate
    
    @Published var bodyCompositions: [BodyComposition] = []
    @Published var currentBMI: Double = 0.0
    @Published var currentBMR: Double = 0.0
    @Published var currentTDEE: Double = 0.0
    @Published var idealWeight: Double = 0.0
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingAddView: Bool = false
    @Published var selectedComposition: BodyComposition?
    
    // MARK: - Services
    private let calculationService: CalculationServiceProtocol
    private let validationService: ValidationServiceProtocol
    private let viewContext: NSManagedObjectContext
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        calculationService: CalculationServiceProtocol = CalorieCalculationService.shared,
        validationService: ValidationServiceProtocol = ValidationService.shared,
        viewContext: NSManagedObjectContext
    ) {
        self.calculationService = calculationService
        self.validationService = validationService
        self.viewContext = viewContext
        
        setupBindings()
        loadBodyCompositions()
        loadLatestComposition()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // 体組成データが変更
