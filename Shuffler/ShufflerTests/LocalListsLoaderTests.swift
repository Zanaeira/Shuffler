//
//  LocalListsLoaderTests.swift
//  ShufflerTests
//
//  Created by Suhayl Ahmed on 20/01/2022.
//

import XCTest

final class LocalListLoader {
    
    private let cache: Cache
    
    init(cache: Cache) {
        self.cache = cache
    }
    
    func load(completion: @escaping (Result<[List], Error>) -> Void) {
        cache.retrieve() { result in
            completion(result)
        }
    }
    
}

protocol Cache {
    func retrieve(completion: @escaping (Result<[List], Error>) -> Void)
}

struct List: Equatable {}

class LocalListsLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageCache() {
        let (cacheSpy, _) = makeSUT()
        
        XCTAssertEqual(cacheSpy.messages, [])
    }
    
    func test_load_sendsRetrieveMessageToCache() {
        let (cacheSpy, sut) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(cacheSpy.messages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (cacheSpy, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(NSError(domain: "Any error", code: 0))) {
            cacheSpy.completeWithError()
        }
    }
    
    func test_load_returnsEmptyListsForEmptyCache() {
        let (cacheSpy, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            cacheSpy.completeWithSuccess([])
        }
    }
    
    func test_load_returnsListsForNonEmptyCache() {
        let (cacheSpy, sut) = makeSUT()
        
        let lists = [List(), List(), List()]
        expect(sut, toCompleteWith: .success(lists)) {
            cacheSpy.completeWithSuccess(lists)
        }
    }
    
    // MARK: - SUT helper
    private func makeSUT() -> (cacheSpy: CacheSpy, sut: LocalListLoader) {
        let cacheSpy = CacheSpy()
        let sut = LocalListLoader(cache: cacheSpy)
        
        return (cacheSpy, sut)
    }
    
    private func expect(_ sut: LocalListLoader, toCompleteWith expectedResult: Result<[List], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
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
    
    // MARK: - CacheSpy helper class
    private final class CacheSpy: Cache {
        
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
