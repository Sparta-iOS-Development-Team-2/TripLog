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
    
    private let shadowView = UIView().then {
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.2
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .clear
    }
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 8.0
        $0.layer.masksToBounds = true
        $0.backgroundColor = .white
    }
    
    private let dateLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .regular)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
    }
    
    private let categoryLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .caption, weight: .regular)
        $0.textColor = .gray
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(shadowView)
        shadowView.addSubview(containerView)
        
        containerView.addSubview(dateLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(exchangeRateLabel)
        
        setupLayout()
    }
    
    private func setupLayout() {
        shadowView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
        }
        
        let firstRowStackView = UIStackView(arrangedSubviews: [titleLabel, amountLabel]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }
        containerView.addSubview(firstRowStackView)
        
        firstRowStackView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        let secondRowStackView = UIStackView(arrangedSubviews: [categoryLabel, exchangeRateLabel]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }
        containerView.addSubview(secondRowStackView)
        
        secondRowStackView.snp.makeConstraints { make in
            make.top.equalTo(firstRowStackView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
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
