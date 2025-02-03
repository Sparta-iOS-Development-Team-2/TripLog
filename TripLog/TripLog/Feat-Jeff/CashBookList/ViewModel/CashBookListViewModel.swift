//
//  CashBookListViewModel.swift
//  TripLog
//
//  Created by jae hoon lee on 1/22/25.
//
import Foundation
import CoreData
import RxSwift
import RxCocoa

class CashBookListViewModel: NSObject, ViewModelType, NSFetchedResultsControllerDelegate {
    
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
                         homecoming: "2025.12.21"),
            ListCellData(tripName: "아시아 출장 2026",
                         note: "대만, 일본",
                         buget: 1000000,
                         departure: "2026.02.11",
                         homecoming: "2026.02.21"),
            ListCellData(tripName: "미국 출장 2026",
                         note: "미국",
                         buget: 3600000,
                         departure: "2026.04.13",
                         homecoming: "2025.04.30")
        ]
    )
    
    struct Input {
        let callViewWillAppear: Observable<Void>
        let addButtonTapped: PublishRelay<Void>
    }
    
    struct Output {
        let showAddListModal: PublishRelay<Void>
        //let updatedData: Observable<[CashBookEntity.Entity]>
        let updatedData: Observable<[SectionOfListCellData]>
        let addCellViewHidden: Driver<Double>
    }
    
    let disposeBag = DisposeBag()
    let showAddListModal = PublishRelay<Void>()
    let updatedDataSubject = BehaviorSubject<[SectionOfListCellData]>(value: [])
    
    /// CoreData의 변화를 감지하기 위한 컨트롤러
    /// (CoreData fetch 요청의 결과를 관리하거나 사용자에게 데이터를 보여주기 위해 사용)
    /// 타입은 제네릭으로 선언, 정렬이 필수적으로 필요
    private lazy var fetchedResultsController: NSFetchedResultsController<CashBookEntity> = {
        let fetchRequest: NSFetchRequest<CashBookEntity> = CashBookEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "departure", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        // CoreData 변경 감지
        controller.delegate = self
        return controller
    }()
    
    override init() {
        super.init()
        insertDummyData()
        
        try? fetchedResultsController.performFetch()
        updateData()
    }
    
    func updateData() {
        
        let fetchedData = fetchedResultsController.fetchedObjects ?? []
        
        let sectionData = [
            SectionOfListCellData(
                identity: UUID(),
                items: fetchedData.map { entity in
                    return ListCellData(
                        tripName: entity.tripName ?? "",
                        note: entity.note ?? "",
                        buget: entity.budget,
                        departure: entity.departure ?? "",
                        homecoming: entity.homecoming ?? ""
                    )
                }
            )
        ]
        
        // RxDataSource 업데이트
        updatedDataSubject.onNext(sectionData)
    }
    
    ///  CoreData 변경 감지 후 Rx 스트림 업데이트
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateData()
    }
    
    
    // 더미데이터 코어데이터에 저장(임시)
    func insertDummyData() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let existingData = CashBookEntity.fetch(context: context)
        
        guard existingData.isEmpty else { return }
        
        for item in dummyData.items {
            let dummykData = MockCashBookModel(
                budget: item.buget,
                departure: item.departure,
                homecoming: item.homecoming,
                note: item.note,
                tripName: item.tripName
            )
            CashBookEntity.save(dummykData, context: context)
        }
    }
    
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
        
        // 코어데이터에 있는 임시 데이터를 불러옴
        let updatedData = updatedDataSubject.asObservable()
        
        let addCellViewHidden = updatedData
            .map { $0.isEmpty ? 1.0 : 0.0 }
            .asDriver(onErrorJustReturn: 0.0)
        
        input.addButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                self.showAddListModal.accept(())
            }).disposed(by: disposeBag)
        
        return Output(
            showAddListModal: showAddListModal,
            updatedData: updatedData,
            addCellViewHidden: addCellViewHidden
        )
    }
    
    func deleteCashBook(with id: UUID) {
        
    }
    
    /// 엔티티 전체 삭제?
    func deleteCashBookList() {
        CoreDataManager.shared.removeEntity(entityName: .CashBookEntity)
    }
    
}

