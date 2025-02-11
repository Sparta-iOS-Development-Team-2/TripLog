import Foundation

struct CurrencyFormatter {
    /// 지원하는 통화 코드와 해당하는 Locale 매핑
    private static let currencyLocales: [String: String] = [
        "USD": "en_US", "JPY": "ja_JP", "KRW": "ko_KR", "GBP": "en_GB", "EUR": "de_DE",
        "CNY": "zh_CN", "AUD": "en_AU", "CAD": "en_CA", "CHF": "de_CH", "HKD": "zh_HK",
        "NZD": "en_NZ", "SGD": "en_SG", "SEK": "sv_SE", "NOK": "nb_NO", "DKK": "da_DK",
        "ZAR": "en_ZA", "INR": "hi_IN", "MYR": "ms_MY", "IDR": "id_ID", "PHP": "en_PH",
        "THB": "th_TH", "MXN": "es_MX", "VND": "vi_VN", "BRL": "pt_BR", "RUB": "ru_RU",
        "SAR": "ar_SA", "TRY": "tr_TR"
    ]

    /// 💰 **소수점이 있을 때만 표시하는 통화 포맷**
    static func formattedCurrency(from amount: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        // ✅ 지정된 currencyCode에 해당하는 locale 적용 (기본값: 현재 Locale)
        if let localeIdentifier = currencyLocales[currencyCode] {
            formatter.locale = Locale(identifier: localeIdentifier)
        } else {
            formatter.locale = Locale.current
        }

        // ✅ 소수점이 있을 경우만 소수점 표시
        if amount.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0  // 정수일 때는 소수점 제거
        } else {
            formatter.minimumFractionDigits = 2  // 소수점이 있을 때는 2자리 표시
            formatter.maximumFractionDigits = 2
        }

        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}
