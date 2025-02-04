import Foundation
import RxSwift
import RxCocoa
import CoreData

class TodayViewModel {
    
    let expenses = BehaviorRelay<[MockMyCashBookModel]>(value: []) // ✅ CoreData 데이터 사용
    let totalAmount = BehaviorRelay<String>(value: "0 원")
    let showAddExpenseModal = PublishRelay<Void>() // ✅ 모달 표시 이벤트 추가

    private let disposeBag = DisposeBag()
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchExpenses() // ✅ CoreData에서 데이터 불러오기
    }

    // ✅ CoreData에서 데이터 가져오기
    func fetchExpenses() {
        let entities = MyCashBookEntity.fetch(context: context)
        let convertedData = entities.map { entity in
            MockMyCashBookModel(
                id: entity.id ?? UUID(),
                note: entity.note ?? "지출",
                category: entity.category ?? "기타",
                amount: entity.amount,
                payment: entity.payment
            )
        }
        expenses.accept(convertedData)
        updateTotalAmount()
    }

    // ✅ CoreData에 지출 항목 추가
    func addExpense(data: MockMyCashBookModel) {
        MyCashBookEntity.save(data, context: context)
        fetchExpenses()  // ✅ 저장 후 다시 불러오기
    }

    // ✅ CoreData에서 지출 항목 삭제
    func deleteExpense(at index: Int) {
        let targetExpense = expenses.value[index]
        MyCashBookEntity.delete(entityID: targetExpense.id, context: context)
        fetchExpenses() // ✅ 삭제 후 다시 불러오기
    }

    // ✅ 총 사용 금액 업데이트
    private func updateTotalAmount() {
        let total = expenses.value.reduce(0) { $0 + $1.amount }
        totalAmount.accept("\(Int(total)) 원")
    }

    // ✅ 모달을 띄우는 이벤트 트리거
    func triggerAddExpenseModal() {
        showAddExpenseModal.accept(())
    }
}
