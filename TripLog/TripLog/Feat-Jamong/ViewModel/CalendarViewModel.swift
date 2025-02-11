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

// 1. CashBookId를 받아오는 로직 [완료]
// 2. CoreData와 연결하여 CashBookId를 통해 데이터를 가져오고 삭제, 수정할 수 있는 로직 [완료]
// 3. ViewController에 Date에 따른 ExpenseLabel 보내주는 로직
// 4. 캘린더뷰 - 지출목록의 Date에 따른 데이터 연결해주는 로직
// 5. 지출목록의 추가하고 삭제할때 바인딩하는 로직

class CalendarViewModel: ViewModelType {
    // MARK: - Input & Output
    struct Input {
        let previousButtonTapped: Observable<Void>
        let nextButtonTapped: Observable<Void>
        let addButtonTapped: Observable<Date>
    }
    
    struct Output {
        let updatedDate: BehaviorRelay<Date>
        let expenses: BehaviorRelay<[MockMyCashBookModel]>
        let addButtonTapped: PublishRelay<Date>
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // 가계부 ID 저장
    private let cashBookID: UUID
    
    // 지출 데이터를 저장
    private let expenseRelay = BehaviorRelay<[MockMyCashBookModel]>(value: [])
    
    // 현재 페이지를 저장하는 Relay
    private let currentPageRelay = BehaviorRelay<Date>(value: Date())
    private let addButtonTapped = PublishRelay<Date>()
    
    
    // MARK: - Initalization
    init(cashBookID: UUID) {
        self.cashBookID = cashBookID
        loadExpenseData()
    }
    
    // MARK: - Method
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
      
        input.addButtonTapped
            .asSignal(onErrorJustReturn: Date())
            .emit(to: addButtonTapped)
            .disposed(by: disposeBag)
        
        return Output(
            updatedDate: self.currentPageRelay,
            expenses: expenseRelay,
            addButtonTapped: self.addButtonTapped
        )
    }
    
    /// Coredata에서 지출 데이터를 로드하여 expenseData에 저장하는 메서드
    func loadExpenseData() {
        let expenses = CoreDataManager.shared.fetch(
            type: MyCashBookEntity.self,
            predicate: cashBookID
        )
        
        // amount외 원화 객체 수정예정
        let models = expenses.map { entity -> MockMyCashBookModel in
            return MockMyCashBookModel(
                amount: entity.amount,
                cashBookID: entity.cashBookID ?? self.cashBookID,
                caculatedAmount: 1234, // TODO: (#102)수정필요
                category: entity.category ?? "",
                country: entity.country ?? "",
                expenseDate: entity.expenseDate ?? Date(),
                note: entity.note ?? "",
                payment: entity.payment
            )
        }
        
        expenseRelay.accept(models)
      
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
    
    /// 지정된 날짜에 해당하는 지출내역을 가져오는 메서드 
    /// - Parameter date: 조회하는 날짜
    /// - Returns: 해당 날짜의 지출 내역 배열
    func expensesForDate(_ date: Date) -> [MockMyCashBookModel] {
        return expenseRelay.value.filter { expense in
            Calendar.current.isDate(expense.expenseDate, inSameDayAs: date)
        }
    }
    
    /// 선택된 날짜의 총 지출 금액을 계산하는 메서드 (amount -> 원화 객체로 수정예정)
    /// - Parameter date: 총 지출 금액을 계산하는 날짜
    /// - Returns: 해당 날짜의 총 지출 금액
    func totalExpense(for date: Date) -> Double {
        let dailyExpenses = expensesForDate(date)
        return dailyExpenses.reduce(0) { $0 + $1.amount }
    }
}
