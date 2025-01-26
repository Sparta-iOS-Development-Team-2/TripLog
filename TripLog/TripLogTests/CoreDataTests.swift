//
//  CoreDataTests.swift
//  TripLogTests
//
//  Created by 황석현 on 1/21/25.
//

import XCTest
import CoreData
@testable import TripLog

final class CoreDataTests: XCTestCase {
    
    var manager: CoreDataManager? = nil
    var mockCashBooks: [MockCashBookModel] = []
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = CoreDataManager.shared
        mockCashBooks = [MockCashBookModel(budget: 1111.1,
                                               departure: "12345678",
                                               homecoming: "12345678",
                                               note: "note1",
                                               tripName: "trip1"),
                             MockCashBookModel(budget: 2222.2,
                                               departure: "23456789",
                                               homecoming: "23456789",
                                               note: "Note2",
                                               tripName: "trip2")]
    }
    
    override func tearDownWithError() throws {
//        manager?.removeAll()
        manager = nil
        try super.tearDownWithError()
    }
    
    func testFetchStoredCurrencyRates() throws {
        // Given: 데이터를 저장할 준비
        manager?.save(type: CurrencyEntity.self, data: CurrencyRate())
        
        // Wait for async operation
        let expectation = XCTestExpectation(description: "Fetching data from API")
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { // API 호출 대기
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        
        // When: 저장된 데이터를 가져옴
        let storedRates = manager?.fetch(type: CurrencyEntity.self)
        debugPrint("storageRates: \(String(describing: storedRates?.count))")
        
        // Then: 데이터를 검증
        XCTAssertTrue(((storedRates?.isEmpty) != nil), "저장된 데이터가 비어 있습니다.")
        
        guard let firstRate = storedRates?[1] else { return }
        
        XCTAssertNotNil(firstRate.currencyCode, "currencyCode가 nil입니다.")
        XCTAssertNotNil(firstRate.currencyName, "currencyName이 nil입니다.")
        XCTAssertGreaterThan(firstRate.baseRate, 0, "baseRate가 0 이하입니다.")
    }
    
    func testCurrencyEntityDelete() throws {
        // 환율 엔티티를 삭제할 수 있다.
    }
    
    /// 가계부 엔티티를 저장/생성할 수 있다.
    func testCashBookEntitySave() throws {
        
        // Give&when: 데이터 생성 & 메서드 호출
        manager?.save(type: CashBookEntity.self, data: mockCashBooks[0])
        
        /** XCTestExpectation = 테스트에서 비동기 작업이 완료될 때까지 기다리는 역할
         .asyncAfter = 비동기 작업을 2초 후에 실행
         fulfill = 비동기 작업이 완료되었음을 XCTest에 알림
         expectation.fulfill()이 호출되지 않으면 타임아웃(=Test Fail)
         */
        let expectation = XCTestExpectation(description: "Saving data to CoreData")
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        // wait = XCTest에게 최대 5초동안 비동기 작업이 완료되기를 기다리도록 지시
        wait(for: [expectation], timeout: 5)
        
        // then: 결과 검증
        print(manager?.fetch(type: CashBookEntity.self) ?? "No CashBookEntity")
        XCTAssertNotEqual(manager?.fetch(type: CashBookEntity.self).count, 0, "데이터가 존재하지 않습니다.")
    }
    
    /// 가계부 엔티티를 불러올 수 있다.
    func testCashBookEntityFetch() throws {
        // give: 값 저장
        for mockItem in mockCashBooks {
            manager?.save(type: CashBookEntity.self, data: mockItem)
        }
        
        let expectation = XCTestExpectation(description: "fetch data from CoreData")
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        
        // when: 메서드 호출
        let fetchData = manager?.fetch(type: CashBookEntity.self)
        
        // then: 결과 검증
        for data in fetchData! {
            print("fetchData: \(data.budget)")
        }
        XCTAssertNotNil(fetchData, "데이터 불러오기 성공")
    }
    
    /// 가계부 엔티티를 검색할 수 있다.
    func testCashBookEntitySearch() throws {
        
        // give: 데이터 저장
        for item in mockCashBooks {
            manager?.save(type: CashBookEntity.self, data: item)
        }
        // give: 검색조건 생성(여행이름)
        let predicate = NSPredicate(format: "tripName CONTAINS[cd] %@", "trip1")
        
        let expectation = XCTestExpectation(description: "search data from CoreData")
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        
        // when: 메서드 호출
        guard let result = manager?.fetch(type: CashBookEntity.self, predicate: predicate) else { return }
        
        // then: 결과 검증
        print("result[0]: \(String(describing: result[0].tripName))")
        XCTAssertEqual(result[0].tripName, "trip1", "테스트 실패: 데이터 검색")
    }
    
    /// 가계부 엔티티를 삭제할 수 있다.
    func testCashBookEntityDelete() throws {
       
        // give: 데이터 저장, 검색
        for item in mockCashBooks {
            manager?.save(type: CashBookEntity.self, data: item)
        }
                
        let expectation = XCTestExpectation(description: "search data from CoreData")
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        
        guard let resultBeforeDelete = manager?.fetch(type: CashBookEntity.self) else { return }
        print("삭제 전 갯수 = \(String(describing: resultBeforeDelete.count))")
        
        let predicate = NSPredicate(format: "tripName CONTAINS[cd] %@", "trip1")
        guard let resultForDelete = manager?.fetch(type: CashBookEntity.self, predicate: predicate) else { return }
        
        // when: 메서드 호출
        manager?.delete(resultForDelete.first!)
        
        // then: 결과 검증
        guard let resultAfterDelete = manager?.fetch(type: CashBookEntity.self) else { return }
        print("삭제 후 갯수 = \(String(describing: resultAfterDelete.count))")
        XCTAssertEqual(resultAfterDelete.count, 1, "테스트 실패: 데이터 삭제")
    }
    
}
