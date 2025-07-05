//
//  SubscriptionService.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 04.07.2025.
//

import Foundation
import ApphudSDK
import SwiftHelper

final class SubscriptionHandler {

    static let shared = SubscriptionHandler()
    private init() {}

    var fetchedProducts: [ApphudProduct] = []

    
    struct SubscriptionOption {
        let product: ApphudProduct
        let unit: String
        let duration: Int
        let price: Double
        let currency: String
        let hasTrial: Bool
        let trialPrice: Double?
        let trialUnit: String?
        let trialDuration: Int?
    }

    @MainActor
    func loadSubscriptionOptions(paywallId: String = "main", timeout: TimeInterval = 10, retryInterval: TimeInterval = 1, completion: @escaping ([SubscriptionOption]) -> Void) {
        let loadingStartTime = Date()
        
        func tryLoading() {
            SwiftHelper.apphudHelper.fetchProducts(paywallID: paywallId) { loadedProducts in
                self.fetchedProducts = loadedProducts
                if !loadedProducts.isEmpty {
                    let options = loadedProducts.compactMap { item -> SubscriptionOption? in
                        guard
                            let subUnit = SwiftHelper.apphudHelper.returnSubscriptionUnit(product: item),
                            let subDuration = SwiftHelper.apphudHelper.returnSubscriptionDuration(product: item)
                        else { return nil }

                        let priceInfo = SwiftHelper.apphudHelper.returnClearPriceAndSymbol(product: item)
                        let clearPrice = priceInfo.price
                        let clearSymbol = priceInfo.symbol

                        return SubscriptionOption(
                            product: item,
                            unit: subUnit,
                            duration: subDuration,
                            price: clearPrice,
                            currency: clearSymbol,
                            hasTrial: false,
                            trialPrice: nil,
                            trialUnit: nil,
                            trialDuration: nil
                        )
                    }
                    completion(options)
                } else {
                    let timePassed = Date().timeIntervalSince(loadingStartTime)
                    if timePassed < timeout {
                        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
                            tryLoading()
                        }
                    } else {
                        completion([])
                    }
                }
            }
        }

        tryLoading()
    }
    
    @MainActor
    var hasActiveSubscription: Bool {
        return SwiftHelper.apphudHelper.isProUser()
    }

    @MainActor
    func buySubscription(_ selectedProduct: ApphudProduct, completion: @escaping (Bool) -> Void) {
        SwiftHelper.apphudHelper.purchaseSubscription(subscription: selectedProduct) { result in
            completion(result)
        }
    }

    @MainActor
    func recoverPurchases(completion: @escaping (Bool) -> Void) {
        SwiftHelper.apphudHelper.restoreAllProducts { wasRestored in
            completion(wasRestored)
        }
    }
}
