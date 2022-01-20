//
//  LocalListLoader.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 20/01/2022.
//

import Foundation

public class LocalListLoader {
    
    private let cache: Cache
    
    public init(cache: Cache) {
        self.cache = cache
    }
    
    public func load(completion: @escaping (Result<[List], Error>) -> Void) {
        cache.retrieve() { result in
            completion(result)
        }
    }
    
}
