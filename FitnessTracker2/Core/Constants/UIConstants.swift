//
//  UIConstants.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import SwiftUI

struct UIConstants {
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let card: CGFloat = 15
    }
    
    // MARK: - Font Sizes
    struct FontSize {
        static let caption: CGFloat = 12
        static let footnote: CGFloat = 13
        static let subheadline: CGFloat = 15
        static let body: CGFloat = 17
        static let headline: CGFloat = 17
        static let title3: CGFloat = 20
        static let title2: CGFloat = 22
        static let title: CGFloat = 28
        static let largeTitle: CGFloat = 34
    }
    
    // MARK: - Dimensions
    struct Dimensions {
        static let buttonHeight: CGFloat = 44
        static let textFieldHeight: CGFloat = 44
        static let toolbarHeight: CGFloat = 44
        static let tabBarHeight: CGFloat = 49
        
        static let fabSize: CGFloat = 56
        static let fabShadowRadius: CGFloat = 4
        static let fabShadowOffset: CGSize = CGSize(width: 0, height: 2)
        
        static let thumbnailSize: CGFloat = 60
        static let photoHeight: CGFloat = 200
        static let chartHeight: CGFloat = 200
        
        static let calendarCellSize: CGFloat = 36
        static let calendarCellSpacing: CGFloat = 8
    }
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.secondary
        static let accent = Color.accentColor
        
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
        
        static let cardBackground = Color(.systemGray6)
        static let backgroundSecondary = Color(.systemBackground)
        
        static let calorieIntake = Color.blue
        static let calorieBurned = Color.orange
        static let calorieNet = Color.green
        static let steps = Color.purple
        
        static let workoutIcon = Color.orange
        static let foodIcon = Color.green
        static let bodyCompositionIcon = Color.blue
    }
    
    // MARK: - Shadows
    struct Shadow {
        static let light = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.2)
        static let heavy = Color.black.opacity(0.3)
        
        static let defaultRadius: CGFloat = 4
        static let defaultOffset = CGSize(width: 0, height: 2)
    }
    
    // MARK: - Animation
    struct Animation {
        static let short: Double = 0.2
        static let medium: Double = 0.3
        static let long: Double = 0.5
        
        static let easeInOut = SwiftUI.Animation.easeInOut
        static let spring = SwiftUI.Animation.spring()
        static let bouncy = SwiftUI.Animation.bouncy
    }
    
    // MARK: - Icons
    struct Icons {
        static let home = "house.fill"
        static let workout = "dumbbell.fill"
        static let food = "fork.knife"
        static let bodyComposition = "person.fill"
        static let settings = "gearshape.fill"
        
        static let add = "plus"
        static let edit = "pencil"
        static let delete = "trash.fill"
        static let camera = "camera.fill"
        static let photo = "photo"
        static let calendar = "calendar"
        
        static let weight = "scalemass"
        static let reps = "number"
        static let sets = "repeat"
        static let calories = "flame.fill"
        static let steps = "figure.walk"
        
        static let up = "chevron.up"
        static let down = "chevron.down"
        static let left = "chevron.left"
        static let right = "chevron.right"
    }
}
