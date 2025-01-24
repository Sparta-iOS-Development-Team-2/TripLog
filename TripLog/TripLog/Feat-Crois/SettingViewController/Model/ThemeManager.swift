//
//  TemeManager.swift
//  TripLog
//
//  Created by 장상경 on 1/24/25.
//

import UIKit

final class ThemeManager {
    private static func applyDarkMode(_ isDarkMode: Bool, for window: UIWindow?) {
        guard let window else { return }
        let transitionView = UIView(frame: window.bounds)
        transitionView.backgroundColor = isDarkMode ? .black : .white
        transitionView.alpha = 0
        window.addSubview(transitionView)
        
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkModeEnabled")
        
        UIView.animate(withDuration: 0.3, animations: {
            transitionView.alpha = 1
        }) { _ in
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            
            UIView.animate(withDuration: 0.3, animations: {
                transitionView.alpha = 0
            }) { _ in
                transitionView.removeFromSuperview()
            }
        }
        
    }
    
    static func loadTheme(for window: UIWindow?) {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        applyDarkMode(isDarkMode, for: window)
    }
}
