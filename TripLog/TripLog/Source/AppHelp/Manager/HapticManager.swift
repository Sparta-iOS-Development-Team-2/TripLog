//
//  HapticManager.swift
//  TripLog
//
//  Created by 장상경 on 2/18/25.
//

import UIKit

enum HapticManager {
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle, view: UIView) {
        if #available(iOS 17.5, *) {
            let generator = UIImpactFeedbackGenerator(style: style, view: view)
            generator.prepare()
            generator.impactOccurred()
        } else {
            // Fallback on earlier versions
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
}
