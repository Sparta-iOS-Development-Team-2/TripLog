//
//  ViewModelType.swift
//  TripLog
//
//  Created by 장상경 on 1/20/25.
//

import RxSwift

/// 모든 뷰모델이 준수할 뷰모델 타입
protocol ViewModelType: AnyObject {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get }
    
    func transform(input: Input) -> Output
}
