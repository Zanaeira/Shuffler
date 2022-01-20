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
    
    func load(completion: @escaping (Error) -> Void) {
        cache.retrieve() { error in
            completion(error)
        }
    }
    
}

protocol Cache {
    func retrieve(completion: @escaping (Error) -> Void)
}

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
        sut.load { error in
            receivedError = error as NSError
            exp.fulfill()
        }
        
        cacheSpy.completeWithError()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError, retrievalError)
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
        var completions: [(Error) -> Void] = []
        
        func retrieve(completion: @escaping (Error) -> Void) {
            messages.append(.retrieve)
            completions.append(completion)
        }
        
        func completeWithError() {
            completions[0](NSError(domain: "Any error", code: 0))
        }
        
    }
    
}
