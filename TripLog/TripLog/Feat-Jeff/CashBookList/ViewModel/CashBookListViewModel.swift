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
    // 임시 코어데이터 역할
    private let itemsRelay = BehaviorRelay<[ListCellData]>(value: [])
    
    var items: [ListCellData] {
        get { itemsRelay.value }
        set { itemsRelay.accept(newValue) }
    }
    
    private var currentIndex = 0
    private var dummyData =
    SectionOfListCellData(
        identity: UUID(),
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
    
    struct Input {
        let callViewWillAppear: Observable<Void>
        let testButtonTapped: PublishRelay<Void>
        let addButtonTapped: PublishRelay<Void>
    }

    struct Output {
        let updatedData: Driver<[SectionOfListCellData]>
        let showAddListModal: PublishRelay<Void>
        let addCellViewHidden: Driver<CGFloat>
    }
    
    let disposeBag = DisposeBag()
    let showAddListModal = PublishRelay<Void>()

    init() {}
    
    /// Input
    /// - callViewWillAppear : ViewWillAppear 호출 시 이벤트
    /// - testButtonTapped : 임시 버튼을 눌렀을 시 이벤트(임시)
    /// - addButtonTapped : 일정 추가하기 버튼 눌렀을 시 이벤트
    ///
    /// Output
    /// - updatedData : CollectionView데이터 SectionOfListCellData형태로 전달
    /// - showAddListModal : 모달 불러오기 메서드 호출
    /// - addCellViewHidden : 일정 추가하기 뷰의 alpha값 방출로 뷰 동작제어
    func transform(input: Input) -> Output {
        let updatedData = itemsRelay
            .map { items in
                return [SectionOfListCellData(identity: UUID(), items: items)]
            }.asDriver(onErrorJustReturn: [])
        
        let addCellViewHidden = itemsRelay
            .map { items -> CGFloat in
                return items.isEmpty ? 1.0 : 0.0
            }.asDriver(onErrorJustReturn: 0.0)
            
        input.testButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                
                guard self.currentIndex < self.dummyData.items.count else { return }
                let newItem = self.dummyData.items[self.currentIndex]
                self.addItem(newItem)
                self.currentIndex += 1
            }).disposed(by: disposeBag)
        
        input.addButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                self.showAddListModal.accept(())
            }).disposed(by: disposeBag)
        
        return Output(
            updatedData: updatedData,
            showAddListModal: showAddListModal,
            addCellViewHidden: addCellViewHidden
        )
    }
    
    /// 임시 데이터 추가(itemsRelay)
    func addItem(_ item: ListCellData) {
        items.append(item)
        print("\(item)")
    }
    
    /// 임시 데이터 삭제(itemsRelay) - 해당 UUID
    func deleteItem(with id: UUID) {
        if let index = items.firstIndex(where: { $0.identity == id }) {
            items.remove(at: index)
        }
    }
    
}
