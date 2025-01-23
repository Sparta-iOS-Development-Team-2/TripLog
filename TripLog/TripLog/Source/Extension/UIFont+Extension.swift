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
        let familyName = "S-CoreDream-"
        
        var weightString: String
        switch weight {
        case .black:
            weightString = "9Black"
        case .bold:
            weightString = "7ExtraBold"
        case .heavy:
            weightString = "8Heavy"
        case .ultraLight:
            weightString = "2ExtraLight"
        case .light:
            weightString = "3Lihgt"
        case .medium:
            weightString = "5Medium"
        case .regular:
            weightString = "4Regular"
        case .semibold:
            weightString = "6Bold"
        case .thin:
            weightString = "1Thin"
        default:
            weightString = "4Regular"
        }
        
        return UIFont(name: "\(familyName)\(weightString)", size: fontSize.rawValue) ?? .systemFont(ofSize: fontSize.rawValue, weight: weight)
    }
    
    static func printAll() {
        familyNames.sorted().forEach { familyName in
            print("*** \(familyName) ***")
            fontNames(forFamilyName: familyName).sorted().forEach { fontName in
                print("\(fontName)")
            }
        }
    }
}
