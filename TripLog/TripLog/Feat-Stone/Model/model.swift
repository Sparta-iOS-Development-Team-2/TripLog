//
//  model.swift
//  TripLog
//
//  Created by 김석준 on 1/20/25.
//

// Model.swift
import Foundation

struct Trip {
    let title: String
    let subtitle: String
    let date: String
    let progress: Float
    let expense: String
    let budget: String
    let balance: String
}

extension Trip {
    static func sampleData() -> [Trip] {
        return [
            Trip(
                title: "도쿄 여행 2024",
                subtitle: "일본",
                date:"2024.01.15 - 2024.01.20",
                progress: 0.5,
                expense: "1,700,000",
                budget: "2,000,000",
                balance: "1,000,000"
            )
        ]
    }
}
