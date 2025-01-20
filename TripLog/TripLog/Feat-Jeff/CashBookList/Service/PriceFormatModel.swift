//
//  PriceFormatModel.swift
//  TripLog
//
//  Created by jae hoon lee on 1/20/25.
//
import Foundation

struct PriceFormatModel {

    // 1000 단위 구분
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()

    static func wonFormat(_ number: Int) -> String {
        let result = formatter.string(from: NSNumber(value: number)) ?? "0"
        return result + " 원"
    }
}
