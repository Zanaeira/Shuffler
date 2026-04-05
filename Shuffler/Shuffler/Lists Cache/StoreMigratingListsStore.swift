//
//  StoreMigratingListsStore.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 05/04/2026.
//

import Foundation

public class StoreMigratingListsStore: ListsStore {

	private let primaryListsStore: ListsStore
	private let fallbackListsStoreToMigrateFrom: ListsStore

	public init(primaryListsStore: ListsStore, fallbackListsStoreToMigrateFrom: ListsStore) {
		self.primaryListsStore = primaryListsStore
		self.fallbackListsStoreToMigrateFrom = fallbackListsStoreToMigrateFrom
	}

	public func retrieve(completion: @escaping (Result<[Shuffler.List], Shuffler.ListError>) -> Void) {
		fallbackListsStoreToMigrateFrom.retrieve { [weak self] result in
			switch result {
			case .success(let fallbackLists):
				if fallbackLists.isEmpty {
					self?.primaryListsStore.retrieve(completion: completion)
				} else {
					self?.primaryListsStore.retrieve { [weak self] result in
						switch result {
						case .success(let lists):
							let difference = fallbackLists.filter { !lists.contains($0) }
							self?.primaryListsStore.append(lists + difference) { result in
								switch result {
								case .success:
									self?.fallbackListsStoreToMigrateFrom.delete(fallbackLists) { result in
										switch result {
										case .success: completion(.success(lists + difference))
										case .failure(let error): completion(.failure(error))
										}
									}
								case .failure(let error): completion(.failure(error))
								}
							}
						case .failure(let error):
							completion(.failure(error))
						}
					}
				}
			case .failure:
				self?.primaryListsStore.retrieve(completion: completion)
			}
		}
	}

	public func insert(_ lists: [Shuffler.List], completion: @escaping (Result<[Shuffler.List], Shuffler.ListError>) -> Void) {
		primaryListsStore.insert(lists, completion: completion)
	}

	public func update(_ list: Shuffler.List, updatedList: Shuffler.List, completion: @escaping (Result<[Shuffler.List], Shuffler.UpdateError>) -> Void) {
		primaryListsStore.update(list, updatedList: updatedList, completion: completion)
	}

	public func append(_ lists: [Shuffler.List], completion: @escaping (Result<[Shuffler.List], Shuffler.ListError>) -> Void) {
		primaryListsStore.append(lists, completion: completion)
	}

	public func delete(_ lists: [Shuffler.List], completion: @escaping (Result<[Shuffler.List], Shuffler.ListError>) -> Void) {
		primaryListsStore.delete(lists, completion: completion)
		fallbackListsStoreToMigrateFrom.delete(lists, completion: completion)
	}

}
