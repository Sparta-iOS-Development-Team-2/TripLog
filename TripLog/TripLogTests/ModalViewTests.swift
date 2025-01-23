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

final class ModalViewTests: XCTestCase {
    
    private var sut: ModalView!
    
    override func setUpWithError() throws {

        sut = ModalView(state: .createNewCashBook)
        try super.setUpWithError()
        
    }

    override func tearDownWithError() throws {

        sut = nil
        try super.tearDownWithError()
        
    }
    
    // 모달뷰의 현태 status를 가져오는 메소드 테스트
    func testCheckModalViewStatus() throws {
        // given (modalView State = .createNewCashBook)
        
        // when
        let result = sut.checkModalStatus().modalTitle
        
        // then
        XCTAssertEqual(result, "새 가계부 만들기", "🚨 ModalView's Status is not createNewCashBook")
        XCTAssertEqual(result, "새 지출내역 추가하기", "🚨 ModalView's Status is not createNewbudget")
        XCTAssertEqual(result, "지출내역 수정하기", "🚨 ModalView's Status is not editBudget")
    }
    
    // 모달뷰의 active 버튼 이벤트 방출 테스트
    func testModalViewActiveButtonTapped() throws {
        // given
        let input = sut.rx.activeButtonTapped
        let disposeBag = DisposeBag()
        var result: String = ""
        
        // when
        input.subscribe(onNext: {
            result = "activeButtonTapped"
        }).disposed(by: disposeBag)
        
        input.accept(())
        
        // then
        XCTAssertEqual(result, "activeButtonTapped", "🚨 activeButtonTapped function is wrong")
    }
    
    // 모달뷰의 취소 버튼 이벤트 방출 테스트
    func testModalViewCancelButtonTapped() throws {
        // given
        let input = sut.rx.cancelButtonTapped
        let disposeBag = DisposeBag()
        var result: String = ""
        
        // when
        input
            .subscribe(onNext: {
                result = "cancelButtonTapped"
            }, onError: { error in
                result = "\(error)"
            }).disposed(by: disposeBag)
        
        input.accept(())
        
        // then
        XCTAssertEqual(result, "cancelButtonTapped", "🚨 cancelButtonTapped function is wrong")
    }
    
}
