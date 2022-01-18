//
//  LocalListLoader.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 18/01/2022.
//

import Foundation

class LocalListLoader: ListLoader {
    
    private var cache = ListCache()
    
    func load(completion: @escaping (Result<[List], Error>) -> Void) {
        cache.retrieve { result in
            switch result {
            case .success(let lists):
                completion(.success(lists))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
}
