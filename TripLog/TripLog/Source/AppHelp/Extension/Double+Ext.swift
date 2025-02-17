//
//  Double+Extension.swift
//  TripLog
//
//  Created by 장상경 on 2/11/25.
//

import Foundation

extension Double {
    var formattedWithFormatter: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
