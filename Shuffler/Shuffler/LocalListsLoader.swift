//
//  LocalListsLoader.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 20/01/2022.
//

import Foundation

public class LocalListsLoader {
    
    private let store: ListsStore
    
    public init(store: ListsStore) {
        self.store = store
    }
    
    public func load(completion: @escaping (Result<[List], Error>) -> Void) {
        store.retrieve() { result in
            completion(result)
        }
    }
    
}
