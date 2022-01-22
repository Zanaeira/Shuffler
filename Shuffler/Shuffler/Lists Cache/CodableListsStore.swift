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
        
        var modelLists: [List] {
            codableLists.map({ $0.modelList })
        }
    }
    
    private let storeUrl: URL
    
    public init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    
    public func retrieve(completion: @escaping (Result<[List], Error>) -> Void) {
        guard let data = try? Data(contentsOf: storeUrl) else {
            completion(.success([]))
            return
        }
        
        do {
            let lists = try JSONDecoder().decode([CodableList].self, from: data)
            completion(.success(lists.map({$0.modelList})))
        } catch {
            completion(.failure(error))
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
                
                var updatedLists = [List]()
                for cachedList in cachedLists {
                    if cachedList.id == list.id {
                        updatedLists.append(updatedList)
                    } else {
                        updatedLists.append(cachedList)
                    }
                }
                
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
    
    public func append(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
        retrieveCachedListsAndAmend(using: lists, by: +, completion: completion)
    }
    
    public func delete(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
        retrieveCachedListsAndAmend(using: lists, by: removingFrom, completion: completion)
    }
    
    private func removingFrom(mainList: [List], lists: [List]) -> [List] {
        mainList.filter({ !lists.contains($0) })
    }
    
    private func retrieveCachedListsAndAmend(using lists: [List], by updatingListsFrom: @escaping ([List], [List]) -> [List], completion: @escaping (Result<[List], Error>) -> Void) {
        retrieve { result in
            switch result {
            case let .success(cachedLists):
                let updatedLists = updatingListsFrom(cachedLists, lists)
                do {
                    let encoded = try JSONEncoder().encode(updatedLists.map(CodableList.init))
                    try encoded.write(to: self.storeUrl)
                    completion(.success(updatedLists))
                } catch {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
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
