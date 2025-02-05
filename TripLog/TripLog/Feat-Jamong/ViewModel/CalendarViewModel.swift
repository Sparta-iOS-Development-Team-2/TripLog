//
//  CalendarViewModel.swift
//  TripLog
//
//  Created by Jamong on 2/3/25.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit
import FSCalendar


class CalendarViewModel: ViewModelType {
    // MARK: - Input & Output
    struct Input {
        let selectedDate: Observable<Date>
        let previousButtonTapped: Observable<Void>
        let nextButtonTapped: Observable<Void>
    }
    
    struct Output {
        let title: Driver<String>
        let updatedDate: Driver<Date>
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // 현재 페이지를 저장하는 Relay
    let currentPageRelay = BehaviorRelay<Date>(value: Date())
    
    // MARK: - Transform Method
    func transform(input: Input) -> Output {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        
        let title = input.selectedDate
            .map { dateFormatter.string(from: $0) }
            .asDriver(onErrorJustReturn: "")
        
        let previousDate = input.previousButtonTapped
            .withLatestFrom(input.selectedDate)
            .map { self.previousMonth(from: $0) }
        
        let nextDate = input.nextButtonTapped
            .withLatestFrom(input.selectedDate)
            .map { self.nextMonth(from: $0) }
        
        let updatedDate = Observable.merge(previousDate, nextDate)
            .do(onNext: { self.currentPageRelay.accept($0) })
            .asDriver(onErrorJustReturn: Date())
        
        return Output(title: title, updatedDate: updatedDate)
    }
    
    // MARK: - Helper Methods
    private func previousMonth(from date: Date) -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: date) ?? date
    }
    
    private func nextMonth(from date: Date) -> Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: date) ?? date
    }
}
