import UIKit
import SnapKit
import Then

final class ExpenseCell: UITableViewCell {
    static let identifier = "ExpenseCell"

    private let containerView = UIView().then {
        $0.layer.masksToBounds = false
        $0.applyBoxStyle()
    }

    private let dateLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .regular)
    }

    private let titleLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .display, weight: .medium)
    }

    private let categoryLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .regular)
        $0.textColor = UIColor(named: "textPlaceholder")
    }

    private let amountLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .display, weight: .bold)
        $0.textAlignment = .right
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

        [dateLabel, titleLabel, categoryLabel, amountLabel, exchangeRateLabel].forEach {
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

        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(16)
            $0.height.equalTo(16)
        }

        firstRowStackView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(4) // ✅ 여백 추가
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

    func configure(date: String, title: String, category: String, amount: String, exchangeRate: String, payment: Bool) {

        let paymentStatus = payment ? "카드" : "현금"

        dateLabel.text = date
        titleLabel.text = title
        categoryLabel.text = "\(category) / \(paymentStatus)"
        amountLabel.text = amount
        exchangeRateLabel.text = exchangeRate
    }
}
