//
//  Expense.swift
//  TripLog
//
//  Created by 김석준 on 1/20/25.
//

import Foundation

struct TestTodayExpense {
    let date: String        // 날짜
    let title: String       // 제목
    let category: String    // 카테고리
    let amount: String     // 지출 금액
    let exchangeRate: String // 환율 금액
}

extension TestTodayExpense {
    // Sample Dummy Data
    static func sampleData() -> [TestTodayExpense] {
        return [
            TestTodayExpense(
                date: "2024.01.15",
                title: "스시 오마카세",
                category: "식비 / 현금",
                amount: "150,000",
                exchangeRate: "140,044 원"
            ),
            TestTodayExpense(
                date: "2024.01.16",
                title: "커피",
                category: "식비 / 카드",
                amount: "5,000",
                exchangeRate: "7,000 원"
            ),
            TestTodayExpense(
                date: "2024.01.17",
                title: "택시 요금",
                category: "교통비 / 현금",
                amount: "20,000",
                exchangeRate: "28,000 원"
            )
        ]
    }
}
