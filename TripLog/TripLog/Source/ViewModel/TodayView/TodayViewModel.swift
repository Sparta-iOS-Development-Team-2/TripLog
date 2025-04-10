import Foundation
import RxSwift
import RxCocoa
import CoreData

final class TodayViewModel: ViewModelType {
    
    struct Input {
        let fetchTrigger: BehaviorRelay<(String, String, UUID)>
        let deleteExpenseTrigger: PublishRelay<(IndexPath, String, String)>
    }
    
    struct Output {
        let expenses: BehaviorRelay<[TodaySectionModel]>
    }
    
    let disposeBag = DisposeBag()
    private let expensesRelay = BehaviorRelay<[TodaySectionModel]>(value: [])
    private let deleteExpenseTrigger = PublishRelay<Void>()
        
    func transform(input: Input) -> Output {
        
        input.fetchTrigger
            .withUnretained(self)
            .map { owner, data -> [TodaySectionModel] in
                let isCardPayment = data.0 == "카드"
                let entities = CoreDataManager.shared.fetch(type: MyCashBookEntity.self, predicate: data.2)
                let expense = entities.map {
                    MyCashBookModel(amount: $0.amount,
                                    cashBookID: $0.cashBookID ?? data.2,
                                    caculatedAmount: $0.caculatedAmount,
                                    category: $0.category ?? "",
                                    country: $0.country ?? "",
                                    expenseDate: $0.expenseDate ?? Date(),
                                    id: $0.id ?? UUID(),
                                    note: $0.note ?? "",
                                    payment: $0.payment
                    )
                }
                    
                if data.0 == "전체" && data.1 == "전체" {
                    return owner.groupByDate(expense)
                } else if data.0 != "전체" && data.1 == "전체" {
                    let filterExpense = expense.filter{ $0.payment == isCardPayment }
                    return owner.groupByDate(filterExpense)
                } else if data.0 == "전체" && data.1 != "전체" {
                    let filterExpense = expense.filter{ $0.category == data.1 }
                    return owner.groupByDate(filterExpense)
                } else {
                    let filterExpense = expense.filter{ $0.payment == isCardPayment && $0.category == data.1 }
                    return owner.groupByDate(filterExpense)
                }
            }
            .asDriver(onErrorJustReturn: [])
            .drive(expensesRelay)
            .disposed(by: disposeBag)
        
        input.deleteExpenseTrigger
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, data in
                let deleteData = owner.filteredExpenseData(for: data.0)
                
                CoreDataManager.shared.delete(type: MyCashBookEntity.self, entityID: deleteData.id)
                input.fetchTrigger.accept((data.1, data.2, deleteData.cashBookID))
            }
            .disposed(by: disposeBag)
        
        return Output( expenses: expensesRelay )
    }
    
    /// 섹션에서 탐색
    private func filteredExpenseData(for indexPath: IndexPath) -> MyCashBookModel {
        let currentSections = self.expensesRelay.value
        
        guard indexPath.section < currentSections.count else {
            print("⚠️ 잘못된 섹션: \(indexPath.section)")
            return MyCashBookModel(amount: 0, cashBookID: UUID(), caculatedAmount: 0, category: "", country: "", expenseDate: Date(), note: "", payment: false)
        }

        let sectionExpenses = currentSections[indexPath.section].items

        guard indexPath.row < sectionExpenses.count else {
            print("⚠️ 잘못된 인덱스: \(indexPath.row)")
            return MyCashBookModel(amount: 0, cashBookID: UUID(), caculatedAmount: 0, category: "", country: "", expenseDate: Date(), note: "", payment: false)
        }

        return sectionExpenses[indexPath.row]
    }

    /// 날짜대로 그룹화 최신날짜가 상단으로 오게 설정
    private func groupByDate(_ expenses: [MyCashBookModel]) -> [TodaySectionModel] {
        let groupedDictionary = Dictionary(grouping: expenses) {
            Date.formattedDateString(from: $0.expenseDate) }
        
        let sortedGroupedDictionary = groupedDictionary.mapValues { expenses in
            expenses.sorted(by: { $0.expenseDate > $1.expenseDate })
        }
        
        return sortedGroupedDictionary.map { TodaySectionModel(date: $0.key, items: $0.value) }
            .sorted { $0.date > $1.date }
    }
}
