//
//  CashBookListViewModel.swift
//  TripLog
//
//  Created by jae hoon lee on 1/22/25.
//
import Foundation
import RxSwift
import RxCocoa

class CashBookListViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    let showAddListModal = PublishRelay<Void>()
    private let itemsRelay = BehaviorRelay<[ListCellData]>(value: [])
    
    var items: [ListCellData] {
        get { itemsRelay.value }
        set { itemsRelay.accept(newValue) }
    }
    
    private var currentIndex = 0
    private var dummyData =
    SectionOfListCellData(
        items: [
            ListCellData(tripName: "여름방학 여행 2025",
                         note: "일본, 미국, 하와이, 스위스, 체코",
                         buget: 26000000,
                         departure: "2025.05.12",
                         homecoming: "2025.06.13"),
            ListCellData(tripName: "가을방학 여행 2025",
                         note: "🇨🇮 🇩🇪 🇹🇷",
                         buget: 3400000,
                         departure: "2025.10.12",
                         homecoming: "2025.10.23"),
            ListCellData(tripName: "겨울방학 여행 2025",
                         note: "대만, 일본, 발리",
                         buget: 5600000,
                         departure: "2025.12.12",
                         homecoming: "2025.12.21")
        ]
    )
    
    //    func deleteItem1(with id: UUID) {
    //        items = items.filter { $0.id != id }
    //    }

    /// Input
    /// callViewWillAppear : ViewWillAppear 호출 시 방출
    /// buttonTapped : 임시 버튼을 눌렀을 시 방출(임시)
    struct Input {
        let callViewWillAppear: Observable<Void>
        let testButtonTapped: PublishRelay<Void>
        let addButtonTapped: PublishRelay<Void>
    }
    
    /// Output
    /// updatedData : SectionOfListCellData로 업데이트(임시)
    struct Output {
        let updatedData: Driver<[SectionOfListCellData]>
        let showAddListModal: PublishRelay<Void>
        let addCellViewHidden: Driver<Bool>
    }
    
    init() {}
    
    func addItem(_ item: ListCellData) {
        items.append(item)
    }
    
    // 섹션을 하나로 고정으로 변경(deletcellrow) index로 지우기 -> 지워진거 이벤트 다시 방출
    func deleteItem(with id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items.remove(at: index)
        }
    }
    
    func transform(input: Input) -> Output {
        let updatedData = itemsRelay
            .map { items in
                [SectionOfListCellData(items: items)]
            }.asDriver(onErrorJustReturn: [])
        
        let addCellViewHidden = itemsRelay
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: true)
        
        // testButtonTapped 이벤트 처리: dummyData에서 새로운 데이터를 추가
        input.testButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                
                // dummyData에서 새로운 데이터 추가
                guard self.currentIndex < self.dummyData.items.count else {
                    return
                }
                let newItem = self.dummyData.items[self.currentIndex]
                self.addItem(newItem)
                self.currentIndex += 1
            })
            .disposed(by: disposeBag)
        
        // addButtonTapped 이벤트 처리: 모달 표시
        input.addButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                self.showAddListModal.accept(())
            })
            .disposed(by: disposeBag)
        
        return Output(
            updatedData: updatedData,
            showAddListModal: showAddListModal,
            addCellViewHidden: addCellViewHidden
        )
    }
}
