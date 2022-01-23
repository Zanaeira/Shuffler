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
            completion(result)
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
        
        expect(sut, toCompleteWith: .success([])) {
            listsStoreSpy.completeWithSuccess()
        }
    }
    
    func test_load_sendsRetrieveMessageToCache() {
        let (listsStoreSpy, sut) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [.retrieve])
    }
    
    func test_load_returnsListsFromNonEmptyCache() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let list = anyList()
        listsStoreSpy.lists = [list]
        
        expect(sut, toCompleteWith: .success([list])) {
            listsStoreSpy.completeWithSuccess()
        }
    }
    
    func test_load_deliversErrorOnCacheError() {
        let (listsStoreSpy, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyError())) {
            listsStoreSpy.completeWithError()
        }
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (listsStoreSpy: ListsStoreSpy, sut: LocalListsManager) {
        let listsStoreSpy = ListsStoreSpy()
        let sut = LocalListsManager(store: listsStoreSpy)
        
        return (listsStoreSpy, sut)
    }
    
    private func expect(_ sut: LocalListsManager, toCompleteWith expectedResult: Result<[List], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load to complete")
        
        sut.load { receivedResult in
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
            completions[0](.failure(anyError()))
        }
        
        func update(_ list: List, updatedList: List, completion: @escaping (Result<[List], UpdateError>) -> Void) {
            
        }
        
        func append(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
            
        }
        
        func delete(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
            
        }
        
    }
    
}
