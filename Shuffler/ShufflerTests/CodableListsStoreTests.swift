//
//  CodableListsStoreTests.swift
//  ShufflerTests
//
//  Created by Suhayl Ahmed on 20/01/2022.
//

import XCTest
import Shuffler

final class CodableListsStore: ListsStore {
    
    private var lists: [List] = []
    
    init(storeUrl: URL) {
        
    }
    
    func retrieve(completion: @escaping (Result<[List], Error>) -> Void) {
        completion(.success(lists))
    }
    
    func insert(_ lists: [List], completion: ((Result<[List], Error>) -> Void)) {
        self.lists = lists
        completion(.success(lists))
    }
    
}

class CodableListsStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableListsStore(storeUrl: URL(string: "www.any-url.com")!)
        
        expect(sut, toRetrieve: .success([])) { }
    }
    
    func test_insert_returnsInsertedListOnEmptyCache() {
        let sut = CodableListsStore(storeUrl: URL(string: "www.any-url.com")!)
        
        let exp = expectation(description: "Wait for insertion to finish")
        
        let lists: [List] = [List(), List()]
        sut.insert(lists) { result in
            switch result {
            case let .success(updatedLists):
                XCTAssertEqual(lists, updatedLists)
            default:
                XCTFail("Expected insert to succeed. Got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_deliversValuesOnNonEmptyCache() {
        let sut = CodableListsStore(storeUrl: URL(string: "www.any-url.com")!)
        
        let lists: [List] = [List(), List()]
        let exp = expectation(description: "Wait for insertion to finish")
        
        sut.insert(lists) { result in
            switch result {
            case let .success(updatedLists):
                XCTAssertEqual(lists, updatedLists)
            default:
                XCTFail("Expected insert to succeed. Got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        expect(sut, toRetrieve: .success(lists)) { }
    }
    
    // MARK: - Helpers
    private func expect(_ sut: CodableListsStore, toRetrieve expectedResult: Result<[List], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load to complete")
        
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedLists), .success(expectedLists)):
                XCTAssertEqual(receivedLists, expectedLists, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result: \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
}
