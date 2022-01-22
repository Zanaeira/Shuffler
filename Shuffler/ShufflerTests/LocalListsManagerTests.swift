//
//  LocalListsManagerTests.swift
//  ShufflerTests
//
//  Created by Suhayl Ahmed on 22/01/2022.
//

import XCTest
import Shuffler

final class LocalListsManager {
    
    init(store: ListsStore) {
        
    }
    
}

class LocalListsManagerTests: XCTestCase {
    
    func test_init_doesNotMessageCache() {
        let listsStoreSpy = ListsStoreSpy()
        _ = LocalListsManager(store: listsStoreSpy)
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, 0)
    }
    
    private class ListsStoreSpy: ListsStore {
        
        var receivedMessages: Int = 0
        
        func retrieve(completion: @escaping (Result<[List], Error>) -> Void) {
            
        }
        
        func update(_ list: List, updatedList: List, completion: @escaping (Result<[List], UpdateError>) -> Void) {
            
        }
        
        func append(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
            
        }
        
        func delete(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
            
        }
        
    }
    
}
