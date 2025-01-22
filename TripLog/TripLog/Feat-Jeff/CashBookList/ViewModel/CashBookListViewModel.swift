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
  
    /// Input
    /// callViewWillAppear : ViewWillAppear 호출 시 방출
    /// buttonTapped : 임시 버튼을 눌렀을 시 방출(임시)
    struct Input {
        let callViewWillAppear: Observable<Void>
        let buttonTapped: Observable<Void>
    }
    
    /// Output
    /// updatedData : SectionOfListCellData로 업데이트(임시)
    struct Output {
        let updatedData: Driver<[SectionOfListCellData]>
    }
    
    init() {}
    
    /// 임시 coreData역할 (초기값 이슈)
    let coreDataValue = BehaviorSubject<[SectionOfListCellData]>(value: [
        .init(state: .emptyState,
              items: [ListCellData(tripName: "",
                                   note: "",
                                   buget: 0,
                                   departure: "",
                                   homecoming: "")])
              ])
    
    // 더미데이터 추가를 위한 인덱스
    private var currentIndex = 0
    
    // 더미데이터 값
    private var dummyData = [
        SectionOfListCellData(
            state: .existState,
            items: [
                ListCellData(tripName: "여름방학 여행 2025",
                             note: "일본, 미국, 하와이, 스위스, 체코",
                             buget: 26000000,
                             departure: "2025.05.12",
                             homecoming: "2025.06.13")
            ]
        ),
        SectionOfListCellData(
            state: .existState,
            items: [
                ListCellData(tripName: "가을방학 여행 2025",
                             note: "🇨🇮 🇩🇪 🇹🇷",
                             buget: 3400000,
                             departure: "2025.10.12",
                             homecoming: "2025.10.23")
            ]
        ),
        SectionOfListCellData(
            state: .existState,
            items: [
                ListCellData(tripName: "겨을방학 여행 2025",
                             note: "대만, 일본, 발리",
                             buget: 5600000,
                             departure: "2025.12.12",
                             homecoming: "2025.12.21")
            ]
        )
    ]
    
    ///
    func transform(input: Input) -> Output {
        // CoreDataValue의 상태를 기반으로 섹션 업데이트
           let updatedData = coreDataValue
               .map { currentSections -> [SectionOfListCellData] in
                   if currentSections.contains(where: { $0.state == .existState }) {
                       // 데이터 섹션이 존재하면 빈 섹션 제거
                       return currentSections.filter { $0.state == .existState }
                   } else {
                       // 데이터 섹션이 없으면 빈 섹션만 반환
                       return [
                           SectionOfListCellData(
                               state: .emptyState,
                               items: [ListCellData(tripName: "", note: "", buget: 0, departure: "", homecoming: "")]
                           )
                       ]
                   }
               }
        /// 가장 최근의 데이터를 결합해 방출(최신상태를 가져옴)
        /// -> 최근 데이터를 임시의 coreData에 저장
        /// 최신값이 
        input.buttonTapped
            .withLatestFrom(coreDataValue)
            .flatMap { [weak self] currentData -> Observable<[SectionOfListCellData]> in
                guard let self = self else { return .just(currentData) }
                
                guard self.currentIndex < self.dummyData.count else { return .just(currentData) }
                
                var updatedData = currentData
                updatedData.append(self.dummyData[self.currentIndex])
                self.currentIndex += 1
                
                return .just(updatedData)
            }
            .bind(to: coreDataValue)
            .disposed(by: disposeBag)
        
        return Output(
           updatedData: coreDataValue.asDriver(onErrorJustReturn: [])
        )
    }
    
}
