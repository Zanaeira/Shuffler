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
    
    func load() {
        cache.retrieve()
    }
    
}

protocol Cache {
    func retrieve()
}

class LocalListsLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageCache() {
        let (cacheSpy, _) = makeSUT()
        
        XCTAssertEqual(cacheSpy.messages, [])
    }
    
    func test_load_sendsRetrieveMessageToCache() {
        let (cacheSpy, sut) = makeSUT()
        
        sut.load()
        
        XCTAssertEqual(cacheSpy.messages, [.retrieve])
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
        
        func retrieve() {
            messages.append(.retrieve)
        }
        
    }
    
}
