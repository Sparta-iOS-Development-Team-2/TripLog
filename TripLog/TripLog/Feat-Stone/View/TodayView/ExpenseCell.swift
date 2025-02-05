//
//  ExpenseCell.swift
//  TripLog
//
//  Created by 김석준 on 1/24/25.
//

import UIKit
import SnapKit
import Then

class ExpenseCell: UITableViewCell {
    static let identifier = "ExpenseCell"

    private let containerView = UIView().then {
        $0.layer.masksToBounds = false // 그림자가 잘리면 안 되므로 false 설정
        $0.applyBoxStyle()
    }

    private let dateLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .regular)
    }

    private let titleLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
    }

    private let categoryLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .regular)
        $0.textColor = UIColor(named: "textPlaceholder")
    }

    private let amountLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .display, weight: .medium)
        $0.textAlignment = .right
    }

    private let exchangeRateLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .body, weight: .bold)
        $0.textColor = UIColor.Personal.normal
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

        contentView.addSubview(containerView)

        [dateLabel, titleLabel, categoryLabel, amountLabel, exchangeRateLabel].forEach {
            containerView.addSubview($0)
        }

        [titleLabel, amountLabel].forEach {
            firstRowStackView.addArrangedSubview($0)
        }
        containerView.addSubview(firstRowStackView)

        [categoryLabel, exchangeRateLabel].forEach{
            secondRowStackView.addArrangedSubview($0)
        }
        containerView.addSubview(secondRowStackView)

        selectionStyle = .none

        setupLayout()
        applyBackgroundColor()
    }

    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }

        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(16)
        }

        firstRowStackView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        secondRowStackView.snp.makeConstraints {
            $0.top.equalTo(firstRowStackView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(date: String, title: String, category: String, amount: String, exchangeRate: String) {
        dateLabel.text = date
        titleLabel.text = title
        categoryLabel.text = category
        amountLabel.text = amount
        exchangeRateLabel.text = exchangeRate
    }
}
