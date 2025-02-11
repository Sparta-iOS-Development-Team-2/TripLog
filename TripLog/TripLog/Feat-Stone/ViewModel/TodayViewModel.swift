import Foundation
import RxSwift
import RxCocoa
import CoreData

class TodayViewModel {
    
    // **Input (사용자 액션)**
    struct Input {
        let fetchTrigger: PublishRelay<UUID> // 특정 cashBookID에 대한 데이터 요청
        let addExpenseTrigger: PublishRelay<MockMyCashBookModel> // 지출 추가 요청
        let deleteExpenseTrigger: PublishRelay<Int> // 특정 인덱스의 지출 삭제 요청
        let showAddExpenseModalTrigger: PublishRelay<Void> // 모달 표시 요청
    }
    
    // **Output (UI 업데이트)**
    struct Output {
        let expenses: Driver<[MockMyCashBookModel]>
        let totalAmount: Driver<String>
        let showAddExpenseModal: Signal<Void>
    }
    
    // **Relay (데이터 관리)**
    private let expensesRelay = BehaviorRelay<[MockMyCashBookModel]>(value: [])
    private let totalAmountRelay = BehaviorRelay<String>(value: "0 원")
    private let showAddExpenseModalRelay = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    // ✅ Input과 Output을 늦게 초기화하기 위해 `lazy` 사용
    lazy var input: Input = {
        return Input(
            fetchTrigger: fetchTrigger,
            addExpenseTrigger: addExpenseTrigger,
            deleteExpenseTrigger: deleteExpenseTrigger,
            showAddExpenseModalTrigger: showAddExpenseModalTrigger
        )
    }()
    
    lazy var output: Output = {
        return Output(
            expenses: expensesRelay.asDriver(),
            totalAmount: totalAmountRelay.asDriver(),
            showAddExpenseModal: showAddExpenseModalRelay.asSignal()
        )
    }()
    
    // ✅ 먼저 Rx 트리거들을 선언 (순서 중요!)
    private let fetchTrigger = PublishRelay<UUID>()
    private let addExpenseTrigger = PublishRelay<MockMyCashBookModel>()
    private let deleteExpenseTrigger = PublishRelay<Int>()
    private let showAddExpenseModalTrigger = PublishRelay<Void>()

    init() {
        // ✅ 특정 cashBookID의 데이터 가져오기
        fetchTrigger
            .flatMapLatest { cashBookID -> Observable<[MockMyCashBookModel]> in
                let predicate = NSPredicate(format: "cashBookID == %@", cashBookID as CVarArg)
                let entities = CoreDataManager.shared.fetch(type: MyCashBookEntity.self, predicate: predicate)
                
                let convertedData = entities.map { entity in
                    MockMyCashBookModel(
                        amount: entity.amount,
                        cashBookID: entity.cashBookID ?? UUID(),
                        caculatedAmount: 1234, // TODO: (#102)수정필요
                        category: entity.category ?? "기타",
                        country: entity.country ?? "USD",
                        expenseDate: entity.expenseDate ?? Date(),
                        id: entity.id ?? UUID(),
                        note: entity.note ?? "지출",
                        payment: entity.payment
                    )
                }
                
                return Observable.just(convertedData)
            }
            .bind(to: expensesRelay)
            .disposed(by: disposeBag)
        
        // ✅ 총 사용 금액 계산
        expensesRelay
            .map { expenses in
                let total = expenses.reduce(0) { $0 + $1.amount }
                return "\(Int(total)) 원"
            }
            .bind(to: totalAmountRelay)
            .disposed(by: disposeBag)
        
        // ✅ 지출 추가 처리 (저장 후 자동으로 fetchTrigger 실행)
        addExpenseTrigger
            .subscribe(onNext: { [weak self] expense in
                guard let self = self else { return }
                CoreDataManager.shared.save(type: MyCashBookEntity.self, data: expense)
                self.fetchTrigger.accept(expense.cashBookID) // ✅ 저장 후 다시 불러오기
            })
            .disposed(by: disposeBag)
        
        // 🔹 지출 삭제 처리 (삭제 후 fetchTrigger 호출)
        deleteExpenseTrigger
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                let currentExpenses = self.expensesRelay.value
                guard index < currentExpenses.count else { return }
                    
                let targetExpense = currentExpenses[index]
                        
                // CoreData에서 삭제
                CoreDataManager.shared.delete(type: MyCashBookEntity.self, entityID: targetExpense.id)
                        
                // ✅ 최신 데이터 다시 불러오기
                self.fetchTrigger.accept(targetExpense.cashBookID)
            })
            .disposed(by: disposeBag)
        
        // ✅ 모달 표시 트리거
        showAddExpenseModalTrigger
            .bind(to: showAddExpenseModalRelay)
            .disposed(by: disposeBag)
    }
}
