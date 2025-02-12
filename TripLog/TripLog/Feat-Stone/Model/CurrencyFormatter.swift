import Foundation

struct CurrencyFormatter {
    /// 통화 코드에 따른 통화 기호 매핑
    private static let currencyCodeToSymbol: [String: String] = [
        "AED": "﷼",
        "AUD": "A$",
        "BHD": "﷼",
        "BND": "B$",
        "CAD": "C$",
        "CHF": "SFr",
        "CNH": "¥",
        "DKK": "kr",
        "EUR": "€",
        "GBP": "£",
        "HKD": "HK$",
        "IDR": "Rp",
        "JPY": "¥",
        "KRW": "₩",
        "KWD": "﷼",
        "MYR": "RM",
        "NOK": "kr",
        "NZD": "NZ$",
        "SAR": "﷼",
        "SEK": "kr",
        "SGD": "S$",
        "THB": "฿",
        "USD": "$"
    ]
    
    /// 💰 **모든 통화 기호가 앞에 오고, 소수점 대신 쉼표(`,`)를 사용**
    static func formattedCurrency(from amount: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale(identifier: "en_US") // 기본 로케일을 설정하여 오류 방지

        // ✅ 천 단위 구분자를 쉼표(`,`)로 강제 설정
        formatter.groupingSeparator = ","

        // ✅ 소수점 대신 쉼표(`,`) 사용
        formatter.decimalSeparator = ","

        // ✅ 소수점이 있을 경우만 소수점 표시
        if amount.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0  // 정수일 때 소수점 제거
        } else {
            formatter.minimumFractionDigits = 2  // 소수점이 있을 때 2자리 표시
            formatter.maximumFractionDigits = 2
        }

        // ✅ 통화 기호를 강제로 설정하여 표시
        let symbol = currencyCodeToSymbol[currencyCode] ?? currencyCode
        formatter.currencySymbol = symbol + " " // 기호를 앞에 배치하고 공백 추가

        // ✅ 최종 포맷된 문자열 반환
        if let formattedString = formatter.string(from: NSNumber(value: amount)) {
            // ✅ 강제로 소수점 `.` → 쉼표 `,` 변환 (최종 확인)
            return formattedString.replacingOccurrences(of: ".", with: ",")
        } else {
            // ✅ 오류 방지를 위해 currencySymbol을 안전하게 언래핑하여 기본값 제공
            return "\(symbol) \(amount)"
        }
    }
}
