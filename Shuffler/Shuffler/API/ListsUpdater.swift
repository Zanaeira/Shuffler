//
//  ListsUpdater.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 26/01/2022.
//

import Foundation

public protocol ListsUpdater {
    typealias Result = Swift.Result<[List], ListError>
    
    func insert(_ lists: [List], completion: @escaping (Result) -> Void)
    func add(_ lists: [List], completion: @escaping (Result) -> Void)
    func addItem(_ item: Item, to list: List, completion: @escaping (Result) -> Void)
    func editName(_ list: List, newName: String, completion: @escaping (Result) -> Void)
    func delete(_ lists: [List], completion: @escaping (Result) -> Void)
    func deleteItem(_ item: Item, from list: List, completion: @escaping (Result) -> Void)
}
