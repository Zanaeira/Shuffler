//
//  LocalListsLoaderTests.swift
//  ShufflerTests
//
//  Created by Suhayl Ahmed on 20/01/2022.
//

import XCTest
import Shuffler

class LocalListsLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageCache() {
        let (listsStoreSpy, _) = makeSUT()
        
        XCTAssertEqual(listsStoreSpy.messages, [])
    }
    
    func test_load_sendsRetrieveMessageToCache() {
        let (listsStoreSpy, sut) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(listsStoreSpy.messages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (listsStoreSpy, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(NSError(domain: "Any error", code: 0))) {
            listsStoreSpy.completeWithError()
        }
    }
    
    func test_load_returnsEmptyListsForEmptyCache() {
        let (listsStoreSpy, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            listsStoreSpy.completeWithSuccess([])
        }
    }
    
    func test_load_returnsListsForNonEmptyCache() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let lists: [List] = [anyList(), anyList(), anyList()]
        expect(sut, toCompleteWith: .success(lists)) {
            listsStoreSpy.completeWithSuccess(lists)
        }
    }
    
    // MARK: - SUT helper
    private func makeSUT() -> (listsStoreSpy: ListsStoreSpy, sut: LocalListsLoader) {
        let listsStoreSpy = ListsStoreSpy()
        let sut = LocalListsLoader(store: listsStoreSpy)
        
        return (listsStoreSpy, sut)
    }
    
    private func expect(_ sut: LocalListsLoader, toCompleteWith expectedResult: Result<[List], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
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
    
    private func anyList() -> List {
        List(id: UUID(), name: "Any List", items: [])
    }
    
    // MARK: - ListsStoreSpy helper class
    private final class ListsStoreSpy: ListsStore {
        
        enum Message {
            case retrieve
        }
        
        var messages: [Message] = []
        var completions: [(Result<[List], Error>) -> Void] = []
        
        func retrieve(completion: @escaping (Result<[List], Error>) -> Void) {
            messages.append(.retrieve)
            completions.append(completion)
        }
        
        func completeWithError() {
            completions[0](.failure(NSError(domain: "Any error", code: 0)))
        }
        
        func completeWithSuccess(_ lists: [List]) {
            completions[0](.success(lists))
        }
        
    }
    
}
