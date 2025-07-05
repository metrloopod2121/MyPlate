//
//  User.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 01.07.2025.
//

import Foundation

struct UserProfile: Codable {
    var gender: Gender
    var age: Int
    var heightCm: Double
    var startWeight: Double
    var currentWeightKg: Double
    var targetWeightKg: Double
    var weightStat: [Date: Double]
    var goal: Goal
    var dietType: DietType
    var activityLevel: ActivityLevel
    var inputHeightUnit: LengthUnit
    var inputWeightUnit: WeightUnit

    
    var totalCalories: Int = 0
    var totalCarbs: Int = 0
    var totalProtein: Int = 0
    var totalFats: Int = 0
}


enum Gender: String, Codable {
    case male, female, other
}

enum Goal: String, Codable {
    case loseWeight, maintain, gainWeight
}

enum DietType: String, Codable {
    case balanced, vegetarian, ketogenic, lowCalorie
}

enum LengthUnit: String, Codable {
    case cm, ft_in
}

enum WeightUnit: String, Codable {
    case kg, lbs
}
