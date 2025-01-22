//
//  ModalViewControllerTests.swift
//  TripLogTests
//
//  Created by 장상경 on 1/22/25.
//

import XCTest
import RxSwift
import RxCocoa
@testable import TripLog

final class ModalViewControllerTests: XCTestCase {
    
    private var sut: ModalViewController!
    
    override func setUpWithError() throws {
        
        sut = ModalViewController(state: .createNewCashBook)
        try super.setUpWithError()
        
    }
    
    override func tearDownWithError() throws {
        
        sut = nil
        try super.tearDownWithError()
        
    }
    
    func testModalViewControllerCompletedAction() throws {
        // given
        let input = sut.rx.completedLogic
        let disposBag = DisposeBag()
        var result: String = ""
        
        // when
        input
            .subscribe(onNext: {
                result = "Completed"
            }, onError: { error in
                result = "\(error)"
            }).disposed(by: disposBag)
        
        input.accept(())
        
        // then
        XCTAssertEqual(result, "Completed", "🚨 ModalViewControllerCompletedAction is wrong")
    }
}
