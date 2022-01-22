//
//  LocalListsManagerTests.swift
//  ShufflerTests
//
//  Created by Suhayl Ahmed on 22/01/2022.
//

import XCTest
import Shuffler

final class LocalListsManager {
    
    private let store: ListsStore
    
    init(store: ListsStore) {
        self.store = store
    }
    
    func load(completion: @escaping ([List]) -> Void) {
        store.retrieve { result in
            if case let .success(lists) = result {
                completion(lists)
            }
        }
    }
    
}

class LocalListsManagerTests: XCTestCase {
    
    func test_init_doesNotMessageCache() {
        let listsStoreSpy = ListsStoreSpy()
        _ = LocalListsManager(store: listsStoreSpy)
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [])
    }
    
    func test_load_onEmptyCacheReturnsEmptyLists() {
        let listsStoreSpy = ListsStoreSpy()
        let sut = LocalListsManager(store: listsStoreSpy)
        
        let exp = expectation(description: "Wait for load to complete.")
        
        sut.load() { lists in
            XCTAssertEqual(lists, [])
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_sendsRetrieveMessageToCache() {
        let listsStoreSpy = ListsStoreSpy()
        let sut = LocalListsManager(store: listsStoreSpy)
        
        sut.load() { _ in }
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [.retrieve])
    }
    private class ListsStoreSpy: ListsStore {
        
        enum Message {
            case retrieve
        }
        
        var receivedMessages: [Message] = []
        
        func retrieve(completion: @escaping (Result<[List], Error>) -> Void) {
            receivedMessages.append(.retrieve)
        }
        
        func update(_ list: List, updatedList: List, completion: @escaping (Result<[List], UpdateError>) -> Void) {
            
        }
        
        func append(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
            
        }
        
        func delete(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
            
        }
        
    }
    
}
