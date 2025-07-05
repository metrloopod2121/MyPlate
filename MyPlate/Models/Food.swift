//
//  Models.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 30.06.2025.
//

import Foundation
import UIKit

struct Meal: Codable {
    var items: [FoodItem]
    let total: NutritionSummary
    var imageData: Data?

    enum CodingKeys: String, CodingKey {
        case items
        case total
        case imageData
    }

    /// Computed property for working with UIImage directly (not codable)
    var image: UIImage? {
        get {
            guard let data = imageData else { return nil }
            return UIImage(data: data)
        }
        set {
            imageData = newValue?.jpegData(compressionQuality: 0.95)
        }
    }
    
    func totalCalories() -> Double {
        var totalKCAL = 0.0
        for item in items {
            totalKCAL += item.kilocaloriesPer100g * Double(Int(item.weight / 100))
        }
        
        return totalKCAL
    }
}

struct FoodItem: Codable {
    let title: String
    let weight: Double
    let kilocaloriesPer100g: Double
    let proteinsPer100g: Double
    let fatsPer100g: Double
    let carbohydratesPer100g: Double
    let fiberPer100g: Double

    enum CodingKeys: String, CodingKey {
        case title, weight
        case kilocaloriesPer100g = "kilocalories_per100g"
        case proteinsPer100g = "proteins_per100g"
        case fatsPer100g = "fats_per100g"
        case carbohydratesPer100g = "carbohydrates_per100g"
        case fiberPer100g = "fiber_per100g"
    }
}

struct NutritionSummary: Codable {
    let kilocaloriesPer100g: Double
    let proteinsPer100g: Double
    let fatsPer100g: Double
    let carbohydratesPer100g: Double
    let fiberPer100g: Double
    let title: String

    enum CodingKeys: String, CodingKey {
        case kilocaloriesPer100g = "kilocalories_per100g"
        case proteinsPer100g = "proteins_per100g"
        case fatsPer100g = "fats_per100g"
        case carbohydratesPer100g = "carbohydrates_per100g"
        case fiberPer100g = "fiber_per100g"
        case title
    }
}
