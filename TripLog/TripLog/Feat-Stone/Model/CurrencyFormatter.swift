//
//  CurrencyFormatter.swift
//  TripLog
//
//  Created by 김석준 on 2/11/25.
//

import Foundation

struct CurrencyFormatter {
    /// 지원하는 통화 코드와 해당하는 Locale 매핑
    private static let currencyLocales: [String: String] = [
        "USD": "en_US", // 미국 달러 ($)
        "JPY": "ja_JP", // 일본 엔 (¥)
        "KRW": "ko_KR", // 대한민국 원 (₩)
        "GBP": "en_GB", // 영국 파운드 (£)
        "EUR": "de_DE", // 유로 (€)
        "CNY": "zh_CN", // 중국 위안 (¥)
        "AUD": "en_AU", // 호주 달러 (A$)
        "CAD": "en_CA", // 캐나다 달러 (C$)
        "CHF": "de_CH", // 스위스 프랑 (CHF)
        "HKD": "zh_HK", // 홍콩 달러 (HK$)
        "NZD": "en_NZ", // 뉴질랜드 달러 (NZ$)
        "SGD": "en_SG", // 싱가포르 달러 (S$)
        "SEK": "sv_SE", // 스웨덴 크로나 (kr)
        "NOK": "nb_NO", // 노르웨이 크로네 (kr)
        "DKK": "da_DK", // 덴마크 크로네 (kr)
        "ZAR": "en_ZA", // 남아프리카 랜드 (R)
        "INR": "hi_IN", // 인도 루피 (₹)
        "MYR": "ms_MY", // 말레이시아 링깃 (RM)
        "IDR": "id_ID", // 인도네시아 루피아 (Rp)
        "PHP": "en_PH", // 필리핀 페소 (₱)
        "THB": "th_TH", // 태국 바트 (฿)
        "MXN": "es_MX", // 멕시코 페소 ($)
        "VND": "vi_VN", // 베트남 동 (₫)
        "BRL": "pt_BR", // 브라질 헤알 (R$)
        "RUB": "ru_RU", // 러시아 루블 (₽)
        "SAR": "ar_SA", // 사우디 리얄 (﷼)
        "TRY": "tr_TR"  // 터키 리라 (₺)
    ]

    /// 금액을 국가별 통화 형식으로 변환
    static func formattedCurrency(from amount: Int, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        // 지정된 currencyCode에 해당하는 locale 적용 (기본값: 현재 Locale)
        if let localeIdentifier = currencyLocales[currencyCode] {
            formatter.locale = Locale(identifier: localeIdentifier)
        } else {
            formatter.locale = Locale.current
        }

        // 통화 기호와 숫자 사이에 공백 추가 (예: "₩ 1,000")
        if let currencySymbol = formatter.currencySymbol {
            formatter.positiveFormat = "\(currencySymbol) #,##0"
        }

        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}
