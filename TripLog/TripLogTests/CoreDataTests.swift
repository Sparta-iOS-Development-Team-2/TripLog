//
//  CoreDataTests.swift
//  TripLogTests
//
//  Created by 황석현 on 1/21/25.
//

import XCTest
@testable import TripLog

final class CoreDataTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFetchStoredCurrencyRates() throws {
        // Given: 데이터를 저장할 준비
        let coreDataManager = CoreDataManager.shared
        coreDataManager.fetchCurrenyRates()
        
        // Wait for async operation
        let expectation = XCTestExpectation(description: "Fetching data from API")
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { // API 호출 대기
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        
        // When: 저장된 데이터를 가져옴
        let storedRates = coreDataManager.fetchStoredCurrencyRates()
        
        // Then: 데이터를 검증
        XCTAssertFalse(storedRates.isEmpty, "저장된 데이터가 비어 있습니다.")
        
        let firstRate = storedRates[1]
        
        XCTAssertNotNil(firstRate.currencyCode, "currencyCode가 nil입니다.")
        XCTAssertNotNil(firstRate.currencyName, "currencyName이 nil입니다.")
        XCTAssertGreaterThan(firstRate.baseRate, 0, "baseRate가 0 이하입니다.")
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
