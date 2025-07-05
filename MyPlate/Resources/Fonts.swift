//
//  Fonts.swift
//  MyPlate
//
//  Created by 𝕄𝕒𝕥𝕧𝕖𝕪 ℙ𝕠𝕕𝕘𝕠𝕣𝕟𝕚𝕪 on 30.06.2025.
//

import Foundation
import UIKit


enum FontWeight: String {
    case regular = "Regular"
    case medium = "Medium"
    case bold = "Bold"
}

struct Fonts {
    
    static func font(size: CGFloat, weight: FontWeight) -> UIFont {
        return UIFont(name: "SFProDisplay-\(weight.rawValue)", size: size) ?? .systemFont(ofSize: size)
    }

}
