import Foundation
import RxSwift
import RxCocoa
import CoreData

final class TodayViewModel: ViewModelType {
    
    // **Input (사용자 액션)**
    struct Input {
        let fetchTrigger: PublishRelay<UUID> // 특정 cashBookID에 대한 데이터 요청
        let deleteExpenseTrigger: PublishRelay<Int> // 특정 인덱스의 지출 삭제 요청
    }
    
    // **Output (UI 업데이트)**
    struct Output {
        let deleteExpenseTrigger: PublishRelay<Void>
        let expenses: BehaviorRelay<[MyCashBookModel]>
    }
    
    let disposeBag = DisposeBag()
    
    // **Relay (데이터 관리)**
    private let expensesRelay = BehaviorRelay<[MyCashBookModel]>(value: [])
    private let deleteExpenseTrigger = PublishRelay<Void>()
    
    func transform(input: Input) -> Output {
        
        // ✅ 특정 cashBookID의 데이터 가져오기
        input.fetchTrigger
            .withUnretained(self)
            .map { owner, cashBookID -> [MyCashBookModel] in
                let entities = CoreDataManager.shared.fetch(type: MyCashBookEntity.self, predicate: cashBookID)
                
                let expense = entities.map {
                    MyCashBookModel(amount: $0.amount,
                                    cashBookID: $0.cashBookID ?? cashBookID,
                                    caculatedAmount: $0.caculatedAmount,
                                    category: $0.category ?? "",
                                    country: $0.country ?? "",
                                    expenseDate: $0.expenseDate ?? Date(),
                                    id: $0.id ?? UUID(),
                                    note: $0.note ?? "",
                                    payment: $0.payment
                    )
                }
                let filteredExpense = owner.filteredTodayExpense(cashBookID: cashBookID, expense)
                
                return filteredExpense
            }
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, data in
                owner.expensesRelay.accept(data)
            }
            .disposed(by: disposeBag)
        
        // 🔹 지출 삭제 처리 (삭제 후 fetchTrigger 호출)
        input.deleteExpenseTrigger
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, index in

                let deleteData = owner.filteredExpenseData(index)
                // ✅ CoreData에서 삭제
                CoreDataManager.shared.delete(type: MyCashBookEntity.self, entityID: deleteData.id)
                owner.deleteExpenseTrigger.accept(())
                
            }
            .disposed(by: disposeBag)
        
        return Output(deleteExpenseTrigger: deleteExpenseTrigger,
                      expenses: expensesRelay
        )
    }
    
    /// 지출 목록을 금일 지출 목록으로 필터링 하는 메소드
    /// - Parameters:
    ///   - cashBookID: 불러올 지출 목록의 가계부 ID
    ///   - expenses: 필터링할 지출 목록
    /// - Returns: 필터링된 지출 목록
    private func filteredTodayExpense(cashBookID: UUID, _ expenses: [MyCashBookModel]) -> [MyCashBookModel] {
        let today = Calendar.current.startOfDay(for: Date()) // 🔹 오늘 날짜 (시간 제거)
        
        return expenses.filter {
            $0.cashBookID == cashBookID &&
            Calendar.current.isDate($0.expenseDate, inSameDayAs: today) // 🔹 오늘 날짜와 같은 데이터만 필터링
        }
    }
    
    /// index를 이용해 특정 지출 내역 데이터를 필터링 하는 메소드
    /// - Parameter index: 필터링 기준 index
    /// - Returns: 필터링된 데이터
    private func filteredExpenseData(_ index: Int) -> MyCashBookModel {
        let currentExpenses = self.expensesRelay.value
        // ✅ 유효한 인덱스인지 확인
        guard index < currentExpenses.count else {
            return .init(amount: 0,
                         cashBookID: UUID(),
                         caculatedAmount: 0,
                         category: "",
                         country: "",
                         expenseDate: Date(),
                         note: "",
                         payment: false)
        }
        
        let targetExpense = currentExpenses.filter { Calendar.current.isDate($0.expenseDate, inSameDayAs: Date()) }[index] // ✅ 인덱스로 요소 가져오기
        
        return targetExpense
    }
}
