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
    
    func delete(_ lists: [List], completion: @escaping (Result<[List], ListError>) -> Void) {
        store.delete(lists) { result in
            if case .failure = result {
                completion(.failure(.listNotFound))
            }
        }
    }
    
}

enum ListError: Error {
    case listNotFound
}

class LocalListsManagerTests: XCTestCase {
    
    func test_init_doesNotMessageCache() {
        let (listsStoreSpy, _) = makeSUT()
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [])
    }
    
    func test_load_onEmptyCacheReturnsEmptyLists() {
        let (listsStoreSpy, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            listsStoreSpy.complete(with: [])
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
        
        expect(sut, toCompleteWith: .success([list])) {
            listsStoreSpy.complete(with: [list])
        }
    }
    
    func test_load_deliversErrorOnCacheError() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let error = anyError()
        
        expect(sut, toCompleteWith: .failure(error)) {
            listsStoreSpy.complete(with: error)
        }
    }
    
    func test_delete_onEmptyCacheDeliversListNotFoundError() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let exp = expectation(description: "Wait for delete to complete")
        
        sut.delete([anyList()]) { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, ListError.listNotFound)
            } else {
                XCTFail("Expected ListError.listNotFound error, got \(result) instead")
                XCTFail("Expected ListErorr.listNotFound error, gpt \(result) instead")
            }
            
            exp.fulfill()
        }
        
        listsStoreSpy.complete(with: ListError.listNotFound)
        
        wait(for: [exp], timeout: 1.0)
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
        
        func retrieve(completion: @escaping (Result<[List], Error>) -> Void) {
            receivedMessages.append(.retrieve)
            completions.append(completion)
        }
        
        func complete(with lists: [List]) {
            completions[0](.success(lists))
        }
        
        func complete(with error: Error) {
            completions[0](.failure(error))
        }
        
        func update(_ list: List, updatedList: List, completion: @escaping (Result<[List], UpdateError>) -> Void) {
            
        }
        
        func append(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
            
        }
        
        func delete(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
            completions.append(completion)
        }
        
    }
    
}
