//
//  TitleLabelView.swift
//  TripLog
//
//  Created by 김석준 on 1/23/25.
//

import UIKit
import SnapKit
import Then

class TitleDateView: UIView {

    private let subtitleLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.textColor = UIColor(named: "textPrimary")
    }
    private let dateLabel = UILabel().then {
        $0.font = UIFont.SCDream(size: .headline, weight: .medium)
        $0.textColor = UIColor(named: "textPrimary")
    }

    init() {
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    func configure(subtitle: String, date: String) {
        subtitleLabel.text = subtitle
        dateLabel.text = date
    }

    private func setupLayout() {
        // 서브뷰 추가
        [subtitleLabel, dateLabel].forEach {
            addSubview($0)
        }

        // 레이아웃 설정
        subtitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
