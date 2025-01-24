//
//  TemeManager.swift
//  TripLog
//
//  Created by 장상경 on 1/24/25.
//

import UIKit

/// 앱의 테마를 관리하는 객체
final class ThemeManager {
    
    /// 앱의 테마를 변경하는 메소드
    /// - Parameters:
    ///   - isDarkMode: 현재 앱의 상태
    ///   - window: 상태를 변경할 window
    private static func applyDarkMode(_ isDarkMode: Bool, for window: UIWindow?) {
        guard let window else { return }
        let transitionView = UIView(frame: window.bounds)
        let darkColor: UIColor = UIColor(red: 17/256, green: 24/256, blue: 39/256, alpha: 1.0)
        transitionView.backgroundColor = isDarkMode ? darkColor : .white
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
    
    /// 현재 앱의 테마 상태를 확인하고 테마를 변경시키는 메소드
    /// - Parameter window: 테마를 변경할 window
    static func loadTheme(for window: UIWindow?) {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        applyDarkMode(isDarkMode, for: window)
    }
}
