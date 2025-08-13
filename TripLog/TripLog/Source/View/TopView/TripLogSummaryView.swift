//
//  TripLogSummaryView.swift
//  TripLog
//
//  Created by 김석준 on 2/12/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

/// 🔹 여행 요약 정보를 표시하는 뷰 (타이틀, 날짜, 예산, 진행 상태, 버튼 포함)
final class TripLogSummaryView: UIView {
    
    private var disposeBag = DisposeBag()
    
    private let titleDateView = TitleDateView()
    private let progressView = TopProgressView()
    fileprivate let buttonStackView = CustomButtonStackView()
    
    // MARK: - Initializer
    init(cashBookData: CashBookModel) {
        super.init(frame: .zero)
        configure(
            subtitle: cashBookData.note,
            date: "\(cashBookData.departure.formattedDate()) - \(cashBookData.homecoming.formattedDate())",
            budget: cashBookData.budget,
            amount: getTotalAmount(cashBookData.id)
        )
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeButtonStyle(_ firstButtonSelected: Bool) {
        buttonStackView.changeButtonStyle(firstButtonSelected)
    }
    
    func updateProgress(_ amount: Int) {
        progressView.updateProgress(amount)
    }
    
}
private extension TripLogSummaryView {
    
    /// ✅ 여행 정보를 설정하는 메서드
    func configure(subtitle: String, date: String, budget: Int, amount: Int) {
        titleDateView.configure(subtitle: subtitle, date: date)
        progressView.setProgress(budget, amount)
    }
    
    func getTotalAmount(_ id: UUID) -> Int {
        let data = CoreDataManager.shared.fetch(type: MyCashBookEntity.self, predicate: id)
        let totalExpense = data.reduce(0) { $0 + Int(round($1.caculatedAmount))}
        
        return totalExpense
    }
    
    func setupLayout() {
        [titleDateView, progressView, buttonStackView].forEach {
            addSubview($0)
        }
        
        titleDateView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        
        progressView.snp.makeConstraints {
            $0.top.equalTo(titleDateView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(64)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(-1)
            $0.bottom.equalToSuperview()
        }
        
    }
}

extension Reactive where Base: TripLogSummaryView {
    var firstButtonTapped: ControlEvent<Void> {
        base.buttonStackView.rx.firstButtonTapped
    }
    
    var secondButtonTapped: ControlEvent<Void> {
        base.buttonStackView.rx.secondButtonTapped
    }
}
