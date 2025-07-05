//
//  APIService.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 03.07.2025.
//

import Foundation
import UIKit
import Alamofire
import ApphudSDK

final class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://api-use-core.store/calories/api/v1"
    private let appId = "eduard.plate.bundle"
    
    private init() {}
    
    // Получение userId асинхронно
    private func getUserId() async -> String {
        await Apphud.userID()
    }
    
    func analyzeMealPhoto(image: UIImage) async throws -> Meal {
        let userId = await getUserId()
        let url = "\(baseURL)/photo2calories?userId=\(userId)&appId=\(appId)"
        print("Request URL: \(url)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Failed to convert image to JPEG data")
            throw NSError(domain: "ImageConversion", code: -1)
        }
        
        print("Starting upload...")
        let uploadResponse = AF.upload(
            multipartFormData: { multipart in
                multipart.append(imageData, withName: "image", fileName: "photo.jpg", mimeType: "image/jpeg")
            },
            to: url,
            method: .post
        )
        
        let response = try await uploadResponse
            .validate()
            .serializingDecodable(Meal.self)
            .response
        
        if let statusCode = response.response?.statusCode {
            print("Response status code: \(statusCode)")
        }
        
        if let data = response.data, let bodyString = String(data: data, encoding: .utf8) {
            print("Response body: \(bodyString)")
        }
        
        if let value = response.value {
            print("Successfully received result")
            return value
        } else if let error = response.error {
            throw error
        } else {
            throw NSError(domain: "UnknownError", code: -1)
        }
    }
    
    func analyzeMealText(description: String) async throws -> Meal {
        guard let encodedDescription = description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid description"])
        }
        
        let userId = await getUserId()
        let urlString = "\(baseURL)/text2calories?userId=\(userId)&appId=\(appId)&description=\(encodedDescription)"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "APIService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        print("Request URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = Data() // пустое тело
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
            if !(200..<300).contains(httpResponse.statusCode) {
                let bodyString = String(data: data, encoding: .utf8) ?? ""
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Response error: \(bodyString)"])
            }
        }
        
        let meal = try JSONDecoder().decode(Meal.self, from: data)
        print("Decoded meal: \(meal)")
        
        return meal
    }
}
