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
        
        let exp = expectation(description: "Wait for retrieve to finish")
        
        sut.retrieve { result in
            switch result {
            case let .success(lists):
                XCTAssertEqual(lists, [])
            default:
                XCTFail("Expected empty list, got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_deliversValuesOnNonEmptyCache() {
        let sut = CodableListsStore(storeUrl: URL(string: "www.any-url.com")!)
        
        let exp = expectation(description: "Wait for insertion to finish")
        
        let lists: [List] = [List(), List()]
        var receivedListsAfterInsertion: [List]?
        sut.insert(lists) { result in
            switch result {
            case let .success(updatedLists):
                receivedListsAfterInsertion = updatedLists
                XCTAssertEqual(lists, updatedLists)
            default:
                XCTFail("Expected insert to succeed. Got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        let exp2 = expectation(description: "Wait for retrieve to finish")
        
        sut.retrieve { result in
            switch result {
            case let .success(lists):
                XCTAssertEqual(lists, receivedListsAfterInsertion)
            default:
                XCTFail("Expected empty list, got \(result) instead.")
            }
            
            exp2.fulfill()
        }
        
        wait(for: [exp2], timeout: 1.0)
    }
    
}
