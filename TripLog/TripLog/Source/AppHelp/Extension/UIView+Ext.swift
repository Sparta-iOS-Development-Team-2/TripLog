//
//  UIView+Ext.swift
//  TripLog
//
//  Created by 장상경 on 2/14/25.
//

import UIKit

// ✅ UIView를 UIImage로 변환하는 확장 함수
extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
