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
    
}

protocol Cache {}

class LocalListsLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageCache() {
        let cacheSpy = CacheSpy()
        let _ = LocalListLoader(cache: cacheSpy)
        
        XCTAssertEqual(cacheSpy.messages, 0)
    }
    
    // MARK: - CacheSpy helper class
    private final class CacheSpy: Cache {
        var messages: Int = 0
    }
    
}
