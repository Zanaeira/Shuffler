//
//  LocalListsManager.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 26/01/2022.
//

import Foundation

public final class LocalListsManager: ListsLoader, ListsUpdater {
    
    private let store: ListsStore
    
    public init(store: ListsStore) {
        self.store = store
    }
    
    public func load(completion: @escaping (Result<[List], Error>) -> Void) {
        store.retrieve(completion: completion)
    }
    
    public func add(_ lists: [List], completion: @escaping (Result<[List], Error>) -> Void) {
        store.append(lists, completion: completion)
    }
    
    public func addItem(_ item: Item, to list: List, completion: @escaping (Result<[List], ListError>) -> Void) {
        let updatedItems = list.items + [item]
        let updatedList = List(id: list.id, name: list.name, items: updatedItems)
        
        store.update(list, updatedList: updatedList) { result in
            switch result {
            case let .success(lists):
                completion(.success(lists))
            case let .failure(error):
                completion(.failure(LocalListsManager.map(error)))
            }
        }
    }
    
    private static func map(_ error: UpdateError) -> ListError {
        if error == .listNotFound {
            return .listNotFound
        }
        
        return .unableToAddItem
    }
    
    public func delete(_ lists: [List], completion: @escaping (Result<[List], ListError>) -> Void) {
        store.delete(lists) { result in
            switch result {
            case let .success(receivedLists):
                completion(.success(receivedLists))
            case .failure:
                completion(.failure(.listNotFound))
            }
        }
    }
    
    public func deleteItem(_ item: Item, from list: List, completion: @escaping (Result<[List], ListError>) -> Void) {
        guard list.items.contains(item) else {
            completion(.failure(.itemNotFound))
            return
        }
        
        let updatedItems = list.items.filter({ $0 != item })
        let updatedList = List(id: list.id, name: list.name, items: updatedItems)
        store.update(list, updatedList: updatedList) { result in
            switch result {
            case let .success(receivedLists):
                completion(.success(receivedLists))
            case .failure:
                completion(.failure(.unableToDeleteItem))
            }
        }
    }
    
}
