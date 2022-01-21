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
        self.lists += lists
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
        
        let lists: [List] = [anyList(), anyList()]
        
        expectInsert(lists, intoSUT: sut, toCompleteWith: .success(lists)) { }
    }
    
    func test_retrieve_deliversValuesOnNonEmptyCache() {
        let sut = CodableListsStore(storeUrl: URL(string: "www.any-url.com")!)
        
        let lists: [List] = [anyList(), anyList()]
        expectInsert(lists, intoSUT: sut, toCompleteWith: .success(lists)) { }
        expect(sut, toRetrieve: .success(lists)) { }
    }
    
    func test_insertTwice_appendsTheListsToTheCurrentCache() {
        let sut = CodableListsStore(storeUrl: URL(string: "www.any-url.com")!)
        
        let lists1 = [anyList(), anyList()]
        let lists2 = [anyList(), anyList(), anyList()]
        
        sut.insert(lists1) { _ in }
        sut.insert(lists2) { _ in }
        
        expect(sut, toRetrieve: .success(lists1 + lists2)) { }
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
    
    private func expectInsert(_ lists: [List], intoSUT sut: CodableListsStore, toCompleteWith expectedResult: Result<[List], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for insertion to finish")
        
        sut.insert(lists) { receivedResult in
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
        
        wait(for: [exp], timeout: 1.0)
    }
    
}
