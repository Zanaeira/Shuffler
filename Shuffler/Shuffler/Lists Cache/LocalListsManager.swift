//
//  LocalListsManager.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 26/01/2022.
//

import Foundation

public final class LocalListsManager: ListsManager {
    
    private let store: ListsStore
    
    public init(store: ListsStore) {
        self.store = store
    }
    
    public func load(completion: @escaping (Result<[List], Error>) -> Void) {
        store.retrieve(completion: completion)
    }
    
    public func insert(_ lists: [List], completion: @escaping (Result<[List],ListsStoreError>) -> Void) {
        store.insert(lists, completion: completion)
    }
    
    public func add(_ lists: [List], completion: @escaping (Result<[List], ListError>) -> Void) {
        store.append(lists) { result in
            switch result {
            case let .success(lists):
                completion(.success(lists))
            case .failure:
                completion(.failure(.unableToAddLists))
            }
        }
    }
    
    public func addItem(_ item: Item, to list: List, completion: @escaping (Result<[List], ListError>) -> Void) {
        let updatedItems = list.items + [item]
        let updatedList = List(id: list.id, name: list.name, items: updatedItems)
        
        store.update(list, updatedList: updatedList) { result in
            switch result {
            case let .success(lists):
                completion(.success(lists))
            case let .failure(error):
                completion(.failure(LocalListsManager.mapNonListNotFoundError(error, toListError: .unableToAddItem)))
            }
        }
    }
    
    public func editName(_ list: List, newName: String, completion: @escaping (Result<[List], ListError>) -> Void) {
        let updatedList = List(id: list.id, name: newName, items: list.items)
        
        store.update(list, updatedList: updatedList) { result in
            switch result {
            case let .success(lists):
                completion(.success(lists))
            case let .failure(error):
                completion(.failure(LocalListsManager.mapNonListNotFoundError(error, toListError: .unableToUpdateList)))
            }
        }
    }
    
    private static func mapNonListNotFoundError(_ error: UpdateError, toListError listError: ListError) -> ListError {
        if error == .listNotFound {
            return .listNotFound
        }
        
        return listError
    }
    
    public func delete(_ lists: [List], completion: @escaping (Result<[List], ListError>) -> Void) {
        store.delete(lists) { result in
            switch result {
            case let .success(receivedLists):
                completion(.success(receivedLists))
            case .failure:
                completion(.failure(.unableToDeleteList))
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
