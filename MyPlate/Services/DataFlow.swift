//
//  DataFlow.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 02.07.2025.
//

import Foundation

class DataFlow {
    
    func loadHistoryArrFromFile() -> [UserHistory]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("UserHistory.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let arr = try JSONDecoder().decode([UserHistory].self, from: data)
            return arr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }
    
    private func saveArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("UserHistory.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    func saveArr(arr: [UserHistory]) {
        do {
            let data = try JSONEncoder().encode(arr) //тут мкассив конвертируем в дату
            try saveArrToFile(data: data)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
    }
    
    // MARK: - UserProfile Persistence

    func loadUserProfileFromFile() -> UserProfile? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("UserProfile.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let profile = try JSONDecoder().decode(UserProfile.self, from: data)
            return profile
        } catch {
            print("Failed to load or decode UserProfile: \(error)")
            return nil
        }
    }

    func saveUserProfileToFile(profile: UserProfile) {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return
        }
        let filePath = documentDirectory.appendingPathComponent("UserProfile.plist")
        do {
            let data = try JSONEncoder().encode(profile)
            try data.write(to: filePath)
        } catch {
            print("Failed to encode or save UserProfile: \(error)")
        }
    }

}

// MARK: - Стрик дней за текущую неделю
extension DataFlow {
    /// Считает текущий стрик дней подряд в рамках текущей недели на основе массива UserHistory
    func currentWeekStreak(from history: [UserHistory]) -> Int {
        let calendar = Calendar.current
        let today = Date()
        
        // Получаем начало недели (понедельник)
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return 0
        }
        
        // Отфильтровываем даты истории только за текущую неделю
        let weekDates = history
            .map { $0.day }
            .filter { $0 >= weekStart && $0 <= today }
            .sorted(by: >) // Сортируем по убыванию: сегодня и назад
        
        var streak = 0
        var currentDate = today
        
        for date in weekDates {
            if calendar.isDate(date, inSameDayAs: currentDate) {
                streak += 1
                // Переходим к предыдущему дню
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
            } else if date < currentDate {
                // Если пропущен день — прерываем подсчёт
                break
            }
        }
        
        return streak
    }
}

 
