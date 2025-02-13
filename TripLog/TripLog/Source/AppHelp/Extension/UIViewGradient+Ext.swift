//
//  UIViewGradient+Extension.swift
//  TripLog
//
//  Created by 장상경 on 2/2/25.
//

import UIKit

extension UIView {
    
    /// UIView의 색상을 Gradient로 변경하는 메소드
    /// - Parameter colors: Gradient를 적용할 컬러
    func applyGradient(colors: [UIColor]) {
        self.removeGradientLayer()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = nil
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = self.layer.cornerRadius
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    /// UIView에 적용된 Gradient Layer를 제거하는 메소드
    private func removeGradientLayer() {
        self.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }
    }
    
    /// UIView에 GradientAnimation을 적용하는 메소드
    /// - Parameter colors: Gradient를 적용할 컬러
    func applyGradientAnimation(colors: [UIColor]) {
        let cgColors: [CGColor] = colors.map { $0.cgColor }
        let changeColors: [CGColor] = cgColors.reversed()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = cgColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = self.layer.cornerRadius
        self.layer.addSublayer(gradientLayer)
        
        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.toValue = changeColors
        colorAnimation.duration = 2
        colorAnimation.autoreverses = true
        colorAnimation.repeatCount = .infinity
        gradientLayer.add(colorAnimation, forKey: "colorChangeAnimation")
    }
}
