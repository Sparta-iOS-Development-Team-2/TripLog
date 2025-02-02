//
//  CustomTableViewCell.swift
//  TripLog
//
//  Created by 김석준 on 1/31/25.
//

import UIKit
import SnapKit

class CustomTableViewCell: UITableViewCell {

    private let titleDateView = TitleDateView()
    private let progressView = ProgressView()
    private let buttonStackView = CustomButtonStackView()
    private let todayViewController = TodayViewController() // TodayViewController 인스턴스 생성

    func configure(subtitle: String, date: String, expense: String, budget: String) {
        // 데이터 설정
        titleDateView.configure(subtitle: subtitle, date: date)
        progressView.configure(expense: expense, budget: budget)

        setupLayout()
        applyBackgroundColor()
    }

    private func setupLayout() {
        // 모든 서브뷰 추가
        [titleDateView, progressView, buttonStackView].forEach {
            contentView.addSubview($0)
        }

        // TodayViewController의 view를 추가
        let todayView = todayViewController.view!
        contentView.addSubview(todayView)

        let screenHeight = UIScreen.main.bounds.height // 기기의 전체 화면 높이 가져오기

        titleDateView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        progressView.snp.makeConstraints {
            $0.top.equalTo(titleDateView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }

        todayView.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(16) // buttonStackView 아래 배치
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16) // 하단 여백 추가
            $0.height.equalTo(screenHeight * 0.6).priority(.required) // 기기 화면 높이의 50%를 사용
        }
        
//        applyBackgroundColor()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
