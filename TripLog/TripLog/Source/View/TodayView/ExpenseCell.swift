import UIKit
import SnapKit
import Then

final class ExpenseCell: UITableViewCell {
    static let identifier = "ExpenseCell"

    private let containerView = UIView().then {
        $0.layer.masksToBounds = false
        $0.applyBoxStyle()
    }

    private let titleLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .display, weight: .medium)
        $0.numberOfLines = 1  // ✅ 한 줄로 제한
        $0.lineBreakMode = .byTruncatingTail  // ✅ 너무 길면 "..." 표시
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) // ✅ 자동으로 축소되도록 설정
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal) // ✅ 다른 뷰가 확장될 수 있도록 설정
    }

    private let categoryLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .regular)
        $0.textColor = UIColor(named: "textPlaceholder")
    }

    private let amountLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .display, weight: .bold)
        $0.textAlignment = .right
        $0.numberOfLines = 1  // ✅ 한 줄만 표시
        $0.lineBreakMode = .byTruncatingTail  // ✅ 너무 길면 "..." 표시
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal) // ✅ 크기가 줄어들지 않도록 설정
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal) // ✅ 다른 뷰가 확장될 수 있도록 설정
    }

    private let exchangeRateLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .body, weight: .medium)
        $0.textColor = .CustomColors.Accent.blue
        $0.textAlignment = .right
    }

    private let firstRowStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }

    private let secondRowStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.isUserInteractionEnabled = true
        selectionStyle = .none

        contentView.addSubview(containerView)

        [titleLabel, categoryLabel, amountLabel, exchangeRateLabel].forEach {
            containerView.addSubview($0)
        }

        [titleLabel, amountLabel].forEach {
            firstRowStackView.addArrangedSubview($0)
        }
        containerView.addSubview(firstRowStackView)

        [categoryLabel, exchangeRateLabel].forEach {
            secondRowStackView.addArrangedSubview($0)
        }
        containerView.addSubview(secondRowStackView)

        setupLayout()
        backgroundColor = .clear
    }

    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalTo(150).priority(.low)
        }
        
        amountLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
        }
        
        firstRowStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16) // ✅ 여백 추가
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }

        secondRowStackView.snp.makeConstraints {
            $0.top.equalTo(firstRowStackView.snp.bottom).offset(4) // ✅ 여백 추가
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, category: String, amount: String, exchangeRate: String, payment: Bool) {

        let paymentStatus = payment ? "카드" : "현금"

        titleLabel.text = title
        categoryLabel.text = "\(paymentStatus) / \(category)"
        amountLabel.text = amount
        exchangeRateLabel.text = exchangeRate
    }
}
