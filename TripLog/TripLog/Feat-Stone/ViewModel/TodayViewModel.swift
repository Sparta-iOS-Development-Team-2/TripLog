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
        let entities = MyCashBookEntity.fetch(context: context, predicate: nil) // ✅ `predicate: nil` 추가
        let convertedData = entities.map { entity in
            MockMyCashBookModel(
                amount: entity.amount,
                cashBookID: entity.cashBookID ?? UUID(),
                category: entity.category ?? "기타",
                country: entity.country ?? "USD", // 기본값 설정
                expenseDate: entity.expenseDate ?? Date(), // 기본값 설정
                id: entity.id ?? UUID(),
                note: entity.note ?? "지출",
                payment: entity.payment
            )
        }
        
        // ✅ 데이터 콘솔에 출력
        print("🔥 CoreData에 저장된 데이터 목록:")
        for data in convertedData {
            print("""
            - ID: \(data.id)
            - 금액: \(data.amount)
            - 카테고리: \(data.category)
            - 설명: \(data.note)
            - 결제 방식: \(data.payment ? "카드" : "현금")
            - 국가: \(data.country)
            - 날짜: \(data.expenseDate)
            """)
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
