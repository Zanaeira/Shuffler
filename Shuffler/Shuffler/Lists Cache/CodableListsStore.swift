//
//  CodableListsStore.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 22/01/2022.
//

import Foundation

public final class CodableListsStore: ListsStore {
    
    private struct Cache: Codable {
        let codableLists: [CodableList]
    }
    
    private let storeUrl: URL
    
    public init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    
    public func retrieve(completion: @escaping (Result<[List], ListError>) -> Void) {
        guard let data = try? Data(contentsOf: storeUrl) else {
            completion(.success([]))
            return
        }
        
        do {
            let lists = try JSONDecoder().decode([CodableList].self, from: data)
            completion(.success(lists.map({$0.modelList})))
        } catch {
            completion(.failure(.unableToLoadLists))
        }
    }
    
    public func insert(_ lists: [List], completion: @escaping (Result<[List], ListError>) -> Void) {
        do {
            let encoded = try JSONEncoder().encode(lists.map(CodableList.init))
            try encoded.write(to: self.storeUrl)
            completion(.success(lists))
        } catch {
            completion(.failure(.unableToInsertLists))
        }
    }
    
    public func update(_ list: List, updatedList: List, completion: @escaping (Result<[List], UpdateError>) -> Void) {
        retrieve { result in
            switch result {
            case let .success(cachedLists):
                guard cachedLists.contains(list) else {
                    completion(.failure(.listNotFound))
                    return
                }
                
                let updatedLists = cachedLists.map({ $0.id == list.id ? updatedList : $0 })
                
                do {
                    let encoded = try JSONEncoder().encode(updatedLists.map(CodableList.init))
                    try encoded.write(to: self.storeUrl)
                    
                    completion(.success(updatedLists))
                } catch {
                    completion(.failure(.couldNotSaveCache))
                }
            case .failure:
                completion(.failure(.couldNotRetrieveCache))
            }
        }
    }
    
    public func append(_ lists: [List], completion: @escaping ((Result<[List], ListError>) -> Void)) {
        retrieveCachedListsAndAmend(by: adding, lists: lists, completion: completion)
    }
    
    public func delete(_ lists: [List], completion: @escaping ((Result<[List], ListError>) -> Void)) {
        retrieveCachedListsAndAmend(by: removing, lists: lists, completion: completion)
    }
    
    private func adding(mainLists: [List], lists: [List]) -> [List] {
        let listsNotAlreadyInMainList = lists.filter({ !mainLists.contains($0) })
        
        return mainLists + listsNotAlreadyInMainList
    }
    
    private func removing(mainList: [List], lists: [List]) -> [List] {
        mainList.filter({ !lists.contains($0) })
    }
    
    private func retrieveCachedListsAndAmend(by updatingListsFrom: @escaping ([List], [List]) -> [List], lists: [List], completion: @escaping (Result<[List], ListError>) -> Void) {
        retrieve { result in
            switch result {
            case let .success(cachedLists):
                let updatedLists = updatingListsFrom(cachedLists, lists)
                do {
                    let encoded = try JSONEncoder().encode(updatedLists.map(CodableList.init))
                    try encoded.write(to: self.storeUrl)
                    completion(.success(updatedLists))
                } catch {
                    completion(.failure(.unableToUpdateList))
                }
            case .failure:
                completion(.failure(.unableToLoadLists))
            }
        }
    }
    
}

// MARK: - Codable List and Item representations
extension CodableListsStore {
    
    private struct CodableList: Codable {
        let id: UUID
        let name: String
        let items: [CodableItem]
        
        init(_ list: List) {
            id = list.id
            name = list.name
            items = list.items.map(CodableItem.init)
        }
        
        var modelList: List {
            List(id: id, name: name, items: items.map({ $0.modelItem }))
        }
    }
    
    private struct CodableItem: Codable {
        let id: UUID
        let text: String
        
        init(_ item: Item) {
            id = item.id
            text = item.text
        }
        
        var modelItem: Item {
            Item(id: id, text: text)
        }
    }
    
}
