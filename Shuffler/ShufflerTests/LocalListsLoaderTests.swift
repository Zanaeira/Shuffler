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
        
        XCTAssertEqual(cacheSpy.messages, 0)
    }
    
    func test_load_sendsMessageToCache() {
        let (cacheSpy, sut) = makeSUT()
        
        sut.load()
        
        XCTAssertEqual(cacheSpy.messages, 1)
    }
    
    // MARK: - SUT helper
    private func makeSUT() -> (cacheSpy: CacheSpy, sut: LocalListLoader) {
        let cacheSpy = CacheSpy()
        let sut = LocalListLoader(cache: cacheSpy)
        
        return (cacheSpy, sut)
    }
    
    // MARK: - CacheSpy helper class
    private final class CacheSpy: Cache {
        
        var messages: Int = 0
        
        func retrieve() {
            messages += 1
        }
        
    }
    
}
