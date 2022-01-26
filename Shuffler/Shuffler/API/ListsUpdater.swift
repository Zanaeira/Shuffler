//
//  ListsUpdater.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 26/01/2022.
//

import Foundation

public protocol ListsUpdater {
    func add(_ lists: [List], completion: @escaping (Result<[List], Error>) -> Void)
    func addItem(_ item: Item, to list: List, completion: @escaping (Result<[List], ListError>) -> Void)
    func delete(_ lists: [List], completion: @escaping (Result<[List], ListError>) -> Void)
    func deleteItem(_ item: Item, from list: List, completion: @escaping (Result<[List], ListError>) -> Void)
}
