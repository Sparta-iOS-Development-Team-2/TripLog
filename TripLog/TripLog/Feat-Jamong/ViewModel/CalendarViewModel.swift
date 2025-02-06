//
//  CalendarViewModel.swift
//  TripLog
//
//  Created by Jamong on 2/3/25.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit
import FSCalendar


class CalendarViewModel: ViewModelType {
    // MARK: - Input & Output
    struct Input {
        let previousButtonTapped: Observable<Void>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let updatedDate: BehaviorRelay<Date>
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // 지출 데이터를 저장
    private var expenseData: [Date: [MockMyCashBookModel]] = [:]
    
    // 선택된 날짜의 지출 데이터를 방출하는 Observable
    let selectedDateExpenses = PublishSubject<[MockMyCashBookModel]>()
    
    // 현재 페이지를 저장하는 Relay
    private let currentPageRelay = BehaviorRelay<Date>(value: Date())
    
    // MARK: - Method
    // expensesData 접근가능 메서드
    func expensesForDate(_ date: Date) -> [MockMyCashBookModel] {
        return expenseData[date] ?? []
    }
    
    /// UserDefaults에서 지출 데이터를 로드하여 expenseData에 저장하는 메서드
    func loadExpenseData() {

    }
    
    /// 선택된 날짜의 총 지출 금액을 계산하는 메서드
    /// - Parameter date: 총 지출 금액을 계산하는 날짜
    /// - Returns: 해당 날짜의 총 지출 금액
    func totalExpense(for date: Date) -> Double {
        let expenses = expenseData[date] ?? []
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    /// ViewModel의 Input을 Output으로 변환하는 메서드
    /// - Parameter input: ViewModel의 Input
    /// - Returns: ViewModel의 Output
    func transform(input: Input) -> Output {
        input.previousButtonTapped
            .withUnretained(self)
            .map { owner, _ -> Date in
                let currentDate = owner.currentPageRelay.value
                let date = owner.previousMonth(from: currentDate)
                return date
            }
            .asSignal(onErrorJustReturn: previousMonth(from: currentPageRelay.value))
            .emit(to: currentPageRelay)
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .withUnretained(self)
            .map { owner, _ -> Date in
                let currentDate = owner.currentPageRelay.value
                let date = owner.nextMonth(from: currentDate)
                return date
            }
            .asSignal(onErrorJustReturn: nextMonth(from: currentPageRelay.value))
            .emit(to: currentPageRelay)
            .disposed(by: disposeBag)
        
        return Output(updatedDate: self.currentPageRelay)
    }
    
    // MARK: - Helper Methods
    /// 현재 날짜로부터 이전 달의 날짜를 반환하는 메서드
    /// - Parameter date: 현재 날짜
    /// - Returns: 이전 달의 날짜
    private func previousMonth(from date: Date) -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: date) ?? date
    }
    
    /// 현재 날짜로부터 다음 달의 날짜를 반환하는 메서드
    /// - Parameter date: 현재 날짜
    /// - Returns: 다음 달의 날짜
    private func nextMonth(from date: Date) -> Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: date) ?? date
    }
}
