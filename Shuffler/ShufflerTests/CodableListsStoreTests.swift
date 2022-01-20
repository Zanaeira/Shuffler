//
//  CodableListsStoreTests.swift
//  ShufflerTests
//
//  Created by Suhayl Ahmed on 20/01/2022.
//

import XCTest
import Shuffler

final class CodableListsStore: ListsStore {
    
    init(storeUrl: URL) {
        
    }
    
    func retrieve(completion: @escaping (Result<[List], Error>) -> Void) {
        completion(.success([]))
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
    
}
