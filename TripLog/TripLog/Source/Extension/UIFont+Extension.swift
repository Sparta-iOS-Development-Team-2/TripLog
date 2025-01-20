//
//  UIFont+Extension.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import Foundation
import UIKit

extension UIFont {
    enum FontSize: CGFloat {
        case caption = 10
        case body = 12
        case headline = 14
        case display = 16
        case title = 24
        case subtitle = 20
    }
    
    static func SCDream(size fontSize: FontSize, weight: UIFont.Weight) -> UIFont {
        let familyName = "SCDream"
        
        var weightString: String
        switch weight {
        case .black:
            weightString = "9"
        case .bold:
            weightString = "7"
        case .heavy:
            weightString = "8"
        case .ultraLight:
            weightString = "2"
        case .light:
            weightString = "3"
        case .medium:
            weightString = "5"
        case .regular:
            weightString = "4"
        case .semibold:
            weightString = "6"
        case .thin:
            weightString = "1"
        default:
            weightString = "4"
        }
        
        return UIFont(name: "\(familyName)\(weightString)", size: fontSize.rawValue) ?? .systemFont(ofSize: fontSize.rawValue, weight: weight)
    }
}
