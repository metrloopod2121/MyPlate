//
//  NutritionCalculator.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 01.07.2025.
//

import Foundation


enum ActivityLevel: Codable {
    case light, moderate, active, veryActive
    
    
    var raw: String {
        switch self {
        case .light: return "low"
        case .moderate: return "moderate"
        case .active: return "high"
        case .veryActive: return "very high"
        }
    }

    var factor: Double {
        switch self {
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
}

struct NutritionPlan {
    let calories: Int
    let proteinGrams: Int
    let fatGrams: Int
    let carbGrams: Int
    let weeksToGoal: Int?
    let estimatedGoalDate: Date?
}

final class NutritionCalculator {

    static func calculate(for profile: UserProfile) -> NutritionPlan {
        let bmr = calculateBMR(for: profile)
        let tdee = bmr * profile.activityLevel.factor
        let adjustedCalories = applyGoalModifier(to: tdee, goal: profile.goal)

        let weightDiffKg = profile.currentWeightKg - profile.targetWeightKg
        let isLosing = profile.goal == .loseWeight
        let effectiveDeficit = isLosing ? tdee - adjustedCalories : adjustedCalories - tdee
        let dailyDeficitKcal = max(effectiveDeficit, 0)

        let kcalPerKg = 7700.0
        let totalKcal = abs(weightDiffKg) * kcalPerKg
        let daysToGoal = dailyDeficitKcal > 0 ? totalKcal / dailyDeficitKcal : nil
        let weeksToGoal = daysToGoal != nil ? Int(round(daysToGoal! / 7)) : nil
        let estimatedGoalDate = weeksToGoal != nil ? Calendar.current.date(byAdding: .day, value: weeksToGoal! * 7, to: Date()) : nil

        let macroSplit = getMacroSplit(for: profile.dietType)

        let protein = adjustedCalories * macroSplit.protein / 4
        let fat = adjustedCalories * macroSplit.fat / 9
        let carbs = adjustedCalories * macroSplit.carbs / 4
        
        var updatedProfile = profile
        updatedProfile.totalCalories = Int(adjustedCalories)
        updatedProfile.totalProtein = Int(protein)
        updatedProfile.totalFats = Int(fat)
        updatedProfile.totalCarbs = Int(carbs)
        DataFlow().saveUserProfileToFile(profile: updatedProfile)

        return NutritionPlan(
            calories: Int(adjustedCalories),
            proteinGrams: Int(protein),
            fatGrams: Int(fat),
            carbGrams: Int(carbs),
            weeksToGoal: weeksToGoal,
            estimatedGoalDate: estimatedGoalDate
        )
    }

    private static func calculateBMR(for profile: UserProfile) -> Double {
        switch profile.gender {
        case .male, .other:
            return 10 * profile.currentWeightKg + 6.25 * profile.heightCm - 5 * Double(profile.age) + 5
        case .female:
            return 10 * profile.currentWeightKg + 6.25 * profile.heightCm - 5 * Double(profile.age) - 161
        }
    }

    private static func applyGoalModifier(to tdee: Double, goal: Goal) -> Double {
        switch goal {
        case .loseWeight:
            return tdee * 0.85
        case .maintain:
            return tdee
        case .gainWeight:
            return tdee * 1.15
        }
    }

    private static func getMacroSplit(for diet: DietType) -> (protein: Double, fat: Double, carbs: Double) {
        switch diet {
        case .balanced:
            return (protein: 0.3, fat: 0.25, carbs: 0.45)
        case .vegetarian:
            return (protein: 0.25, fat: 0.3, carbs: 0.45)
        case .ketogenic:
            return (protein: 0.2, fat: 0.7, carbs: 0.1)
        case .lowCalorie:
            return (protein: 0.35, fat: 0.25, carbs: 0.4)
        }
    }
}
