//
//  UITextField+Extension.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import Foundation
import UIKit

extension UITextField {
    func setPlaceholder(title: String, color: UIColor) {
        let title = title
        self.attributedPlaceholder = NSAttributedString(
            string: title,
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
    }
}
