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

final class CalendarViewModel: ViewModelType {
    // MARK: - Input & Output
    struct Input {
        let previousButtonTapped: Observable<Void>
        let nextButtonTapped: Observable<Void>
        let addButtonTapped: Observable<Void>
        let didSelected: PublishRelay<Date>
    }
    
    struct Output {
        let updatedDate: BehaviorRelay<Date>
        let expenses: BehaviorRelay<(date: Date, data: [MyCashBookModel], balance: Int)>
        let addButtonTapped: PublishRelay<Date>
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // 가계부 ID 저장
    let cashBookID: UUID
    private let balance: Int
    
    // 지출 데이터를 저장
    private let expenseRelay = BehaviorRelay<[MyCashBookModel]>(value: [])
    
    // 선택 날짜의 지출 데이터를 저장
    private let selectedDateData = PublishRelay<([MyCashBookModel], Date)>()
    
    // 셀 데이트 저장
    var selectedDate = Date()
    
    // 현재 페이지를 저장하는 Relay
    private let currentPageRelay = BehaviorRelay<Date>(value: Date())
    private let addButtonTapped = PublishRelay<Date>()
    private let expensesData = BehaviorRelay<(date: Date, data: [MyCashBookModel], balance: Int)>(value: (Date(), [], 0))
    
    
    // MARK: - Initalization
    init(cashBookID: UUID, balance: Int) {
        self.cashBookID = cashBookID
        self.balance = balance
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
            .withUnretained(self)
            .map { owner, _ -> Date in
                owner.selectedDate
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] date in
                self?.addButtonTapped.accept(date)
            }.disposed(by: disposeBag)
            
        
        input.didSelected
            .withUnretained(self)
            .map { owner, date -> (date: Date, data: [MyCashBookModel], balance: Int) in
                owner.selectedDate = date
                let remainingBudget = owner.calculateRemainingBudget(upTo: date)
                return (date, owner.expensesForDate(date: date), remainingBudget)
            }
            .asDriver(onErrorDriveWith: .empty())
            .drive{ [weak self] data in
                self?.expensesData.accept(data)
            }
            .disposed(by: disposeBag)
        
        expenseRelay
            .withUnretained(self)
            .map { owner, _ -> (date: Date, data: [MyCashBookModel], balance: Int) in
                let remainingBudget = owner.calculateRemainingBudget(upTo: owner.selectedDate)
                return (owner.selectedDate, owner.expensesForDate(date: owner.selectedDate), remainingBudget)
            }
            .asDriver(onErrorDriveWith: .empty())
            .drive{ [weak self] data in
                self?.expensesData.accept(data)
            }
            .disposed(by: disposeBag)
        
        return Output(
            updatedDate: self.currentPageRelay,
            expenses: expensesData,
            addButtonTapped: self.addButtonTapped
        )
    }
    
    // MARK: - CoreData Methods
    /// Coredata에서 지출 데이터를 로드하여 expenseData에 저장하는 메서드
    func loadExpenseData() {
        let expenses = CoreDataManager.shared.fetch(
            type: MyCashBookEntity.self,
            predicate: cashBookID
        )
        
        let models = expenses.compactMap { entity -> MyCashBookModel? in
            guard let entityID = entity.cashBookID,
                  entityID == self.cashBookID else { return nil }
            
            return MyCashBookModel(
                amount: entity.amount,
                cashBookID: entity.cashBookID ?? self.cashBookID,
                caculatedAmount: entity.caculatedAmount,
                category: entity.category ?? "",
                country: entity.country ?? "",
                expenseDate: entity.expenseDate ?? self.selectedDate,
                id: entity.id ?? UUID(), // ID도 명시적으로 설정
                note: entity.note ?? "",
                payment: entity.payment
            )
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.expenseRelay.accept(models)
            
            // 현재 선택된 날짜의 데이터도 업데이트
            if let self = self {
                let remainingBudget = self.calculateRemainingBudget(upTo: self.selectedDate)
                let currentData = (
                    self.selectedDate,
                    self.expensesForDate(date: self.selectedDate),
                    remainingBudget
                )
                self.expensesData.accept(currentData)
            }
        }
    }
    
    /// 기존 지출 데이터를 수정하는 메서드
    /// - Parameter expense: 수정할 지출 데이터 모델
    func updateExpense(_ expense: MyCashBookModel) {
        CoreDataManager.shared.update(
            type: MyCashBookEntity.self,
            entityID: expense.id,
            data: expense
        )
        debugPrint("수정 완료")
        loadExpenseData()
    }
    
    /// 지출 데이터를 삭제하는 메서드
    /// - Parameter id: 삭제할 지출 데이터의 ID
    func deleteExpense(id: UUID) {
        CoreDataManager.shared.delete(
            type: MyCashBookEntity.self,
            entityID: id
        )
        debugPrint("삭제 완료")
        loadExpenseData()
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
    func expensesForDate(date: Date) -> [MyCashBookModel] {
        return expenseRelay.value.filter { expense in
            Calendar.current.isDate(expense.expenseDate, inSameDayAs: date)
        }
    }
    
    /// 선택된 날짜의 총 지출 금액을 계산하는 메서드
    /// - Parameter date: 총 지출 금액을 계산하는 날짜
    /// - Returns: 해당 날짜의 총 지출 금액
    func totalExpense(date: Date) -> Int {
        let dailyExpenses = expensesForDate(date: date)
        return dailyExpenses.reduce(0) { $0 + Int(round($1.caculatedAmount)) }
    }
    
    /// 특정 날짜까지의 예산 잔액을 계산하는 메서드
    /// - Parameter date: 계산할 기준 날짜
    /// - Returns: 해당 날짜까지의 예산 잔액
    func calculateRemainingBudget(upTo date: Date) -> Int {
        // date를 기준으로 적용
        let targetDate = Calendar.current.startOfDay(for: date)
        // 해당 날짜까지의 모든 지출 필터링
        let allExpenses = expenseRelay.value.filter { expense in
            Calendar.current.isDate(expense.expenseDate, inSameDayAs: date) || expense.expenseDate < date
        }
        // 총 지출 계산
        let totalExpense = allExpenses.reduce(0) { $0 + Int(round($1.caculatedAmount)) }
        // 초기 예산에서 총 지출을 빼서 잔액 계산
        return balance - totalExpense
    }
}
