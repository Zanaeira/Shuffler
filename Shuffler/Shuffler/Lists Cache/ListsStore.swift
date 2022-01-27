//
//  ListsStore.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 20/01/2022.
//

import Foundation

public protocol ListsStore {
    func retrieve(completion: @escaping (Result<[List], Error>) -> Void)
    func insert(_ lists: [List], completion: @escaping (Result<[List],ListError>) -> Void)
    func update(_ list: List, updatedList: List, completion: @escaping (Result<[List], UpdateError>) -> Void)
    func append(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void))
    func delete(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void))
}
