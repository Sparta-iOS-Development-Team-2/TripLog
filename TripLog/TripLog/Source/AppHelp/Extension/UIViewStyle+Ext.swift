//
//  shadow.swift
//  TripLog
//
//  Created by Jamong on 1/22/25.
//

import UIKit

/**
사용방법

1. 스타일 적용 (ViewController)
- 단일 스타일 적용:
  view.applyBoxStyle()          // Box 스타일 (그림자 + 테두리 + 배경색)
  view.applyTabBarStyle()       // TabBar 스타일 (그림자 + 배경색)
  view.applyFloatingButtonStyle() // Floating Button 스타일 (그림자 + 굵은 테두리)
  view.applyTextFieldStyle()    // TextField 스타일 (테두리 + 배경색)
  view.applyButtonStyle()       // Button 스타일 (테두리 + 배경색)
  view.applyViewStyle()         // View 스타일 (테두리 + 그림자 + 배경색)

2. 그림자 최적화 설정
- viewDidLayoutSubviews()에서 그림자 경로 설정 필수 (ViewController)
  override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      boxView.layer.shadowPath = boxView.shadowPath()
      tabBarView.layer.shadowPath = tabBarView.shadowPath()
      floatingButton.layer.shadowPath = floatingButton.shadowPath()
      viewStyleTest.layer.shadowPath = viewStyleTest.shadowPath()
  }

3. 다크모드 대응
- traitCollectionDidChange에서 스타일 재적용
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      super.traitCollectionDidChange(previousTraitCollection)
      
      // 스타일 다시 적용하면 배경색도 자동으로 적용됨
      boxView.applyBoxStyle()
      tabBarView.applyTabBarStyle()
      ...
      
      // 버튼 텍스트 색상만 별도 업데이트 필요
      let isDark = traitCollection.userInterfaceStyle == .dark
      button.setTitleColor(isDark ? .white : .black, for: .normal)
  }

예시 코드:
private lazy var boxView: UIView = {
    let view = UIView()
    view.applyBoxStyle()  // 스타일 적용하면 배경색도 자동 설정
    return view
}()
*/


// MARK: - Check Dark Mode
extension UIView {
    /// 다크모드에 따라 값을 반환하는 함수
    /// - Parameters:
    ///   - darkValue: 다크모드일 때 사용할 값
    ///   - lightValue: 라이트모드일 때 사용할 갑
    /// - Returns: 현재 상태에 맞는 값을 반환
    func darkModeCheck<T>(_ darkValue: T, _ lightValue: T) -> T {
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        return isDarkMode ? darkValue : lightValue
    }
}

// MARK: - UIView Shadow Path
extension UIView {
    /// 그림자를 미리 계산하여 성능(리소스)를 최적화하는 함수
    /// - Returns: 현재 뷰의 bounds와 cornerRadius에 맞는 그림자
    /// - Note: 그림자 경로를 명시적으로 지정하여 iOS가 매 프레임마다 그림자를 계산하는 것을 방지
    func shadowPath() -> CGPath {
        return UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}

// MARK: - UIView Background Extension
extension UIView {
    /// 배경색 적용하는 함수
    func applyBackgroundColor() {
        backgroundColor = UIColor.CustomColors.Background.background
    }
}


// MARK: - UIView Shadow Extension
extension UIView {
    /// Box Shadow
    func applyBoxShadow() {
        layer.shadowColor = darkModeCheck(UIColor.white.cgColor, UIColor.black.cgColor)
        layer.shadowOpacity = darkModeCheck(0.25, 0.15)
        layer.shadowRadius = 1.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.masksToBounds = false
    }
    
    /// TabBar Shadow
    func applyTabBarShadow() {
        layer.shadowColor = darkModeCheck(UIColor.white.cgColor, UIColor.black.cgColor)
        layer.shadowOpacity = darkModeCheck(0.3, 0.1)
        layer.shadowRadius = 1.5
        layer.shadowOffset = CGSize(width: 0, height: -3)
        layer.masksToBounds = false
    }
    
    /// Floating Button Shadow
    func applyFloatingButtonShadow() {
        layer.shadowColor = darkModeCheck(UIColor.white.cgColor, UIColor.black.cgColor)
        layer.shadowOpacity = darkModeCheck(0.2, 0.1)
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.masksToBounds = false
    }
    
    /// View Shadow
    func applyViewShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 1
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.masksToBounds = false
    }
    
    /// Popover View Shadow
    func applyPopoverViewShadow() {
        layer.shadowColor = UIColor.CustomColors.Text.textPrimary.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.masksToBounds = false
    }
}

// MARK: - UIView Border Extension
extension UIView {
    /// Box Stroke
    func applyBoxStroke(){
        layer.borderWidth = 1
        layer.borderColor = UIColor.CustomColors.Border.border.cgColor
    }
    
/// TextField Stroke
    func applyTextFieldStroke() {
        layer.borderWidth = 1
        layer.borderColor = darkModeCheck(UIColor.white.withAlphaComponent(0.15).cgColor, UIColor.black.withAlphaComponent(0.1).cgColor)
    }
    
    /// Button Stroke
    func applyButtonStroke() {
        layer.borderWidth = 1
        layer.borderColor = darkModeCheck(UIColor.white.withAlphaComponent(0.15).cgColor, UIColor.black.withAlphaComponent(0.1).cgColor)
    }
    
    /// Floating Button Stroke
    func applyFloatingButtonStroke() {
        layer.borderWidth = 5
        layer.borderColor = darkModeCheck(UIColor.CustomColors.Background.background.cgColor, UIColor.CustomColors.Background.background.cgColor)
    }
    
    /// View Stroke
    func applyViewStroke() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.CustomColors.Border.border.cgColor
    }
}

// MARK: - UIView Corner Radius Extensions
extension UIView {
    /// 둥근 모서리 적용하는 함수
    /// - Parameter radius: 모서리 값 (기본값: 12)
    func applyCornerRadius(_ radius: CGFloat = 12) {
        layer.cornerRadius = radius
    }
}

// MARK: - UIView Style Combinations
extension UIView {
    /// Box Style
    func applyBoxStyle() {
        applyCornerRadius()
        applyBoxShadow()
        applyBoxStroke()
        applyBackgroundColor()
    }
    
    /// TabBar Style
    func applyTabBarStyle() {
        applyTabBarShadow()
        applyBackgroundColor()
    }
    
    /// Floating Button Style
    func applyFloatingButtonStyle() {
        applyCornerRadius()
        applyFloatingButtonShadow()
        applyFloatingButtonStroke()
        applyBackgroundColor()
    }
    
    /// TextField Style
    func applyTextFieldStyle() {
        applyCornerRadius(8)  // TextField는 8로 설정
        applyTextFieldStroke()
        applyBackgroundColor()
    }
    
    /// Button Style
    func applyButtonStyle() {
        applyCornerRadius()
        applyButtonStroke()
        applyBackgroundColor()
    }
    
    /// Button Style(Blue)
    func applyButtonBlueStyle() {
        applyCornerRadius()
        applyButtonStroke()
        backgroundColor = UIColor.CustomColors.Accent.blue
    }
    
    /// View Style
    func applyViewStyle() {
        applyCornerRadius()
        applyViewShadow()
        applyViewStroke()
        applyBackgroundColor()
    }
    
    /// Center button(tabbar)
    func applyTabBarButtonStyle() {
        applyCornerRadius(32)
        applyViewShadow()
        applyFloatingButtonStroke()
    }
    
    /// popover custom Style
    func applyPopoverButtonStyle() {
        applyPopoverViewShadow()
        applyBackgroundColor()
    }
}
