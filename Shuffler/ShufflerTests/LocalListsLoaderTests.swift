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
        let cacheSpy = CacheSpy()
        let _ = LocalListLoader(cache: cacheSpy)
        
        XCTAssertEqual(cacheSpy.messages, 0)
    }
    
    func test_load_sendsMessageToCache() {
        let cacheSpy = CacheSpy()
        let sut = LocalListLoader(cache: cacheSpy)
        
        sut.load()
        
        XCTAssertEqual(cacheSpy.messages, 1)
    }
    
    // MARK: - CacheSpy helper class
    private final class CacheSpy: Cache {
        
        var messages: Int = 0
        
        func retrieve() {
            messages += 1
        }
        
    }
    
}
