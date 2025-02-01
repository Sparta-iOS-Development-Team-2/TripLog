//
//  CustomTabBarViewModel.swift
//  TripLog
//
//  Created by jae hoon lee on 1/31/25.
//

import RxSwift
import RxCocoa
import UIKit

enum TabBarState {
    case cashBookList
    case setting
}

final class CustomTabBarViewModel: ViewModelType {
    
    let disposeBag = DisposeBag()
    // 초기 상태는 가계부리스트로 설정
    let currentState = BehaviorRelay<TabBarState>(value: .cashBookList)
    let showAddListModal = PublishRelay<Void>()
    
    struct Input {
        let cashBookTapped: PublishRelay<Void>
        let settingTapped: PublishRelay<Void>
        let tabBarAddButtonTapped: PublishRelay<Void>
    }
    
    struct Output {
        let currentState: Driver<TabBarState>
        let isAddButtonEnable: Driver<Bool>
        let showAddListModal: PublishRelay<Void>
    }
    
    /// Input
    /// - cashBookTapped : 탭바의 가계부 탭 선택시 이벤트
    /// - settingTapped : 탭바의 설정 탭 선택시 이벤트
    /// - tabBarAddButtonTapped : 탭바의 추가하기 버튼 눌렀을 시 이벤트
    ///
    /// Output
    /// - currentState : 탭바의 상태를 업데이트
    /// - isAddButtonEnable : 탭바의 상태에 따라 탭바 버튼의 상태 변화
    /// - showAddListModal : 모달 불러오기 메서드 호출
    func transform(input: Input) -> Output {
        
        // 가계부 탭 상태로 변경
        input.cashBookTapped
            .map { TabBarState.cashBookList }
            .bind(to: currentState)
            .disposed(by: disposeBag)
        
        // 설정 탭 상태로 변경
        input.settingTapped
            .map { TabBarState.setting }
            .bind(to: currentState)
            .disposed(by: disposeBag)
        
        // 탭바 추가버튼 동작
        input.tabBarAddButtonTapped
            .asSignal(onErrorSignalWith: .empty())
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                self.showAddListModal.accept(())
            }).disposed(by: disposeBag)
        
        // 탭의 상태에 따른 탭바 추가버튼 활성화
        let isAddButtonEnable = currentState
            .map { $0 == .cashBookList }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
        
        return Output(
            currentState: currentState.asDriver(),
            isAddButtonEnable: isAddButtonEnable,
            showAddListModal: showAddListModal
        )
    }
    
}
