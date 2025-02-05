import Foundation
import RxSwift
import RxCocoa
import CoreData

class TodayViewModel {
    
    let expenses = BehaviorRelay<[MockMyCashBookModel]>(value: []) // CoreData 데이터 사용
    let totalAmount = BehaviorRelay<String>(value: "0 원")
    let showAddExpenseModal = PublishRelay<Void>() // 모달 표시 이벤트 추가

    private let disposeBag = DisposeBag()
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // 🔹 특정 cashBookID를 가진 데이터만 가져오도록 수정
    func fetchExpenses(for cashBookID: UUID) {
        let predicate = NSPredicate(format: "cashBookID == %@", cashBookID as CVarArg)
        let entities = MyCashBookEntity.fetch(context: context, predicate: predicate) // ✅ 특정 ID 필터링
        
        let convertedData = entities.compactMap { entity -> MockMyCashBookModel? in
            guard entity.cashBookID == cashBookID else { return nil } // ✅ ID가 nil이 아닌 경우만 처리
            return MockMyCashBookModel(
                amount: entity.amount,
                cashBookID: entity.cashBookID ?? cashBookID, // ✅ 기존 데이터 유지
                category: entity.category ?? "기타",
                country: entity.country ?? "USD",
                expenseDate: entity.expenseDate ?? Date(),
                id: cashBookID, // ✅ TopViewController에서 전달받은 UUID를 그대로 사용
                note: entity.note ?? "지출",
                payment: entity.payment
            )
        }
        
        // 🔥 콘솔 출력 (디버깅용)
        print("🔥 CoreData에서 \(cashBookID) 관련 데이터 목록:")
        for data in convertedData {
            print("""
            - ID: \(data.id)  // ✅ TopViewController의 UUID인지 확인
            - 금액: \(data.amount)
            - 카테고리: \(data.category)
            - 설명: \(data.note)
            - 결제 방식: \(data.payment ? "카드" : "현금")
            - 국가: \(data.country)
            - 날짜: \(data.expenseDate)
            """)
        }
        
        expenses.accept(convertedData) // ✅ 필터링된 데이터만 저장
        updateTotalAmount()
    }

    
    func fetchAllExpenses() {
        let entities = MyCashBookEntity.fetch(context: context, predicate: nil) // 🔹 모든 데이터 가져오기

        let convertedData = entities.map { entity in
            MockMyCashBookModel(
                amount: entity.amount,
                cashBookID: entity.cashBookID ?? UUID(),
                category: entity.category ?? "기타",
                country: entity.country ?? "USD",
                expenseDate: entity.expenseDate ?? Date(),
                id: entity.id ?? UUID(),
                note: entity.note ?? "지출",
                payment: entity.payment
            )
        }

        // 🔥 콘솔 출력 (모든 데이터 확인)
        print("🔥 CoreData에 저장된 모든 데이터 목록:")
        for data in convertedData {
            print("""
            ------------------------------
            - ID: \(data.id)
            - 가계부 ID: \(data.cashBookID)
            - 금액: \(data.amount)
            - 카테고리: \(data.category)
            - 설명: \(data.note)
            - 결제 방식: \(data.payment ? "카드" : "현금")
            - 국가: \(data.country)
            - 날짜: \(data.expenseDate)
            ------------------------------
            """)
        }
    }


    // CoreData에 지출 항목 추가
    func addExpense(data: MockMyCashBookModel) {
        MyCashBookEntity.save(data, context: context)
        fetchExpenses(for: data.cashBookID)  // 🔹 특정 cashBookID만 다시 불러오기
    }

    // CoreData에서 지출 항목 삭제
    func deleteExpense(at index: Int) {
        let targetExpense = expenses.value[index]
        MyCashBookEntity.delete(entityID: targetExpense.id, context: context)
        fetchExpenses(for: targetExpense.cashBookID) // 🔹 특정 cashBookID만 다시 불러오기
    }

    // 총 사용 금액 업데이트
    private func updateTotalAmount() {
        let total = expenses.value.reduce(0) { $0 + $1.amount }
        totalAmount.accept("\(Int(total)) 원")
    }

    // 모달을 띄우는 이벤트 트리거
    func triggerAddExpenseModal() {
        showAddExpenseModal.accept(())
    }
}
