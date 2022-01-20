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
        let retrievalError = NSError(domain: "Any error", code: 0)
        
        let exp = expectation(description: "Wait for load to complete")
        
        var receivedError: NSError?
        sut.load { result in
            if case let Result.failure(error) = result {
                receivedError = error as NSError
            }
            exp.fulfill()
        }
        
        cacheSpy.completeWithError()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError, retrievalError)
    }
    
    func test_load_returnsEmptyListsForEmptyCache() {
        let (cacheSpy, sut) = makeSUT()
        
        let exp = expectation(description: "Wait for load to complete")
        
        var receivedLists: [List]?
        sut.load { result in
            if case let Result.success(lists) = result {
                receivedLists = lists
            }
            exp.fulfill()
        }
        
        cacheSpy.completeWithSuccess([])
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedLists, [])
    }
    
    // MARK: - SUT helper
    private func makeSUT() -> (cacheSpy: CacheSpy, sut: LocalListLoader) {
        let cacheSpy = CacheSpy()
        let sut = LocalListLoader(cache: cacheSpy)
        
        return (cacheSpy, sut)
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
