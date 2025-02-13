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

final class CashBookListViewModel: NSObject, ViewModelType, NSFetchedResultsControllerDelegate {
    
    struct Input {
        let callViewWillAppear: Observable<Void>
        let addButtonTapped: PublishRelay<Void>
    }
    
    struct Output {
        let showAddListModal: PublishRelay<Void>
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
        
        // 정렬 설정(1순위 출발날짜, 2순위 도착날짜)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "departure", ascending: true),
            NSSortDescriptor(key: "homecoming", ascending: true)
        ]
        
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
        
        try? fetchedResultsController.performFetch()
        updateData()
    }
    
    private func updateData() {
        
        let fetchedData = fetchedResultsController.fetchedObjects ?? []
        
        // 패치 결과로 업데이트
        let sectionData: [SectionOfListCellData] = fetchedData.isEmpty ? [] : [
            SectionOfListCellData(
                id: UUID(), // 섹션 구분
                items: fetchedData.map { entity in
                    return CashBookModel(
                        id: entity.id ?? UUID(),
                        tripName: entity.tripName ?? "",
                        note: entity.note ?? "",
                        budget: Int(entity.budget),
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
        do {
            // 최신 데이터 반영
            try fetchedResultsController.performFetch()
        } catch {
            debugPrint("패치 실패: \(error)")
        }
        updateData()
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
        
        let updatedData = updatedDataSubject
            .asObservable()
        
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
    
}

