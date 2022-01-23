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
    
    func load(completion: @escaping (Result<[List], Error>) -> Void) {
        store.retrieve { result in
            switch result {
            case let .success(lists):
                completion(.success(lists))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
}

class LocalListsManagerTests: XCTestCase {
    
    func test_init_doesNotMessageCache() {
        let (listsStoreSpy, _) = makeSUT()
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [])
    }
    
    func test_load_onEmptyCacheReturnsEmptyLists() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let exp = expectation(description: "Wait for load to complete.")
        
        sut.load() { result in
            if case let .success(lists) = result {
                XCTAssertEqual(lists, [])
            } else {
                XCTFail("Expected empty list, got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        listsStoreSpy.completeWithSuccess()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_sendsRetrieveMessageToCache() {
        let (listsStoreSpy, sut) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [.retrieve])
    }
    
    func test_load_returnsListsFromNonEmptyCache() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let exp = expectation(description: "Wait for load to complete.")
        
        let list = anyList()
        listsStoreSpy.lists = [list]
        
        sut.load() { result in
            if case let .success(lists) = result {
                XCTAssertEqual(lists, [list])
            } else {
                XCTFail("Expected empty list, got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        listsStoreSpy.completeWithSuccess()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversErrorOnCacheError() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let exp = expectation(description: "Wait for load to complete.")
        
        sut.load() { result in
            switch result {
            case .success: XCTFail("Expected error, got \(result)")
            case .failure: break
            }
            
            exp.fulfill()
        }
        
        listsStoreSpy.completeWithError()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (listsStoreSpy: ListsStoreSpy, sut: LocalListsManager) {
        let listsStoreSpy = ListsStoreSpy()
        let sut = LocalListsManager(store: listsStoreSpy)
        
        return (listsStoreSpy, sut)
    }
    
    private class ListsStoreSpy: ListsStore {
        
        enum Message {
            case retrieve
        }
        
        var completions: [(Result<[List], Error>) -> Void] = []
        var receivedMessages: [Message] = []
        var lists: [List] = []
        
        func retrieve(completion: @escaping (Result<[List], Error>) -> Void) {
            receivedMessages.append(.retrieve)
            completions.append(completion)
        }
        
        func completeWithSuccess() {
            completions[0](.success(lists))
        }
        
        func completeWithError() {
            completions[0](.failure(NSError(domain: "Test Error", code: 0)))
        }
        
        func update(_ list: List, updatedList: List, completion: @escaping (Result<[List], UpdateError>) -> Void) {
            
        }
        
        func append(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
            
        }
        
        func delete(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
            
        }
        
    }
    
}
