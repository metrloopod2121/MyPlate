//
//  UserHistory.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 02.07.2025.
//

import Foundation
import UIKit

struct UserHistory: Codable {
    var day: Date
    var history: [Meal]
    
    var totalCaloriesFromMeals: Int {
        let caloriesFromMeals = history.reduce(0) { sum, meal in
            sum + meal.items.reduce(0) { $0 + Int($1.kilocaloriesPer100g * $1.weight / 100) }
        }
        return caloriesFromMeals
    }
    
    var totalProteinsFromMeals: Int {
        history.reduce(0) { sum, meal in
            sum + meal.items.reduce(0) { $0 + Int($1.proteinsPer100g * $1.weight / 100) }
        }
    }

    var totalFatsFromMeals: Int {
        history.reduce(0) { sum, meal in
            sum + meal.items.reduce(0) { $0 + Int($1.fatsPer100g * $1.weight / 100) }
        }
    }

    var totalCarbsFromMeals: Int {
        history.reduce(0) { sum, meal in
            sum + meal.items.reduce(0) { $0 + Int($1.carbohydratesPer100g * $1.weight / 100) }
        }
    }
}
