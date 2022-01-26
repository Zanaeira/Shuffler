//
//  LocalListsManagerTests.swift
//  ShufflerTests
//
//  Created by Suhayl Ahmed on 22/01/2022.
//

import XCTest
import Shuffler

final class LocalListsManager {
    
    private let store: ListsStore
    
    init(store: ListsStore) {
        self.store = store
    }
    
    func load(completion: @escaping (Result<[List], Error>) -> Void) {
        store.retrieve(completion: completion)
    }
    
    func add(_ lists: [List], completion: @escaping (Result<[List], Error>) -> Void) {
        store.append(lists, completion: completion)
    }
    
    func addItem(_ item: Item, to list: List, completion: @escaping (ListError) -> Void) {
        store.update(list, updatedList: list) { _ in }
        completion(.listNotFound)
    }
    
    func delete(_ lists: [List], completion: @escaping (Result<[List], ListError>) -> Void) {
        store.delete(lists) { result in
            switch result {
            case let .success(receivedLists):
                completion(.success(receivedLists))
            case .failure:
                completion(.failure(.listNotFound))
            }
        }
    }
    
    func deleteItem(_ item: Item, from list: List, completion: @escaping (Result<[List], ListError>) -> Void) {
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

enum ListError: Error {
    case listNotFound
    case itemNotFound
    case unableToDeleteItem
}

class LocalListsManagerTests: XCTestCase {
    
    func test_init_doesNotMessageCache() {
        let (listsStoreSpy, _) = makeSUT()
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [])
    }
    
    func test_load_onEmptyCacheReturnsEmptyLists() {
        let (listsStoreSpy, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            listsStoreSpy.complete(with: [])
        }
    }
    
    func test_load_sendsRetrieveMessageToCache() {
        let (listsStoreSpy, sut) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [.retrieve])
    }
    
    func test_load_returnsListsFromNonEmptyCache() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let list = anyList()
        
        expect(sut, toCompleteWith: .success([list])) {
            listsStoreSpy.complete(with: [list])
        }
    }
    
    func test_load_deliversErrorOnCacheError() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let error = anyError()
        
        expect(sut, toCompleteWith: .failure(error)) {
            listsStoreSpy.complete(with: error)
        }
    }
    
    func test_delete_onEmptyCacheDeliversListNotFoundError() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let exp = expectation(description: "Wait for delete to complete")
        
        sut.delete([anyList()]) { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, ListError.listNotFound)
            } else {
                XCTFail("Expected ListError.listNotFound error, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        listsStoreSpy.complete(with: ListError.listNotFound)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_delete_sendsDeleteMessageToCache() {
        let (listsStoreSpy, sut) = makeSUT()
        
        sut.delete([]) { _ in }
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [.delete])
    }
    
    func test_delete_deliversValuesOnSuccessfulDeletion() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let list1 = anyList()
        let list2 = anyList()
        let list3 = anyList()
        
        let exp = expectation(description: "Wait for delete to finish")
        
        sut.delete([list1]) { result in
            if case let .success(receivedLists) = result {
                XCTAssertEqual(receivedLists, [list2, list3])
            } else {
                XCTFail("Expected [list2, list3], got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        listsStoreSpy.complete(with: [list2, list3])
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_deleteItem_deliversItemNotFoundErrorIfItemNotInList() {
        let (_, sut) = makeSUT()
        
        let item1 = Item(id: UUID(), text: "Item 1")
        let item2 = Item(id: UUID(), text: "Item 2")
        let item3 = Item(id: UUID(), text: "Item 3")
        let list = List(id: UUID(), name: "My List", items: [item1, item2])
        
        let exp = expectation(description: "Wait for delete to finish")
        
        sut.deleteItem(item3, from: list) { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, ListError.itemNotFound)
            } else {
                XCTFail("Expected itemNotFound, got \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_deleteItem_deliversItemsOnSuccessfulDeletion() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let item1 = Item(id: UUID(), text: "Item 1")
        let item2 = Item(id: UUID(), text: "Item 2")
        let item3 = Item(id: UUID(), text: "Item 3")
        let list = List(id: UUID(), name: "My List", items: [item1, item2, item3])
        let expectedList = List(id: list.id, name: list.name, items: [item1, item3])
        
        let exp = expectation(description: "Wait for delete to finish")
        
        sut.deleteItem(item2, from: list) { result in
            if case let .success(receivedLists) = result {
                XCTAssertEqual(receivedLists, [expectedList])
            } else {
                XCTFail("Expected \(expectedList), got \(result) instead")
            }
            exp.fulfill()
        }
        
        listsStoreSpy.completeDeletion(with: [expectedList])
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_deleteItem_doesNotSendMessageToCacheOnItemNotFoundError() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let list = anyList()
        let item = Item(id: UUID(), text: "Any Item")
        
        sut.deleteItem(item, from: list) { _ in }
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [])
    }
    
    func test_deleteItem_sendsMessageToCacheOnSuccessfulDeletion() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let item1 = Item(id: UUID(), text: "Item 1")
        let item2 = Item(id: UUID(), text: "Item 1")
        let list = List(id: UUID(), name: "My List", items: [item1, item2])
        
        sut.deleteItem(item1, from: list) { _ in }
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [.update])
    }
    
    func test_deleteItem_deliversUnableToDeleteItemErrorOnCacheUpdateError() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let item1 = Item(id: UUID(), text: "Item 1")
        let item2 = Item(id: UUID(), text: "Item 1")
        let list = List(id: UUID(), name: "My List", items: [item1, item2])
        
        let exp = expectation(description: "Wait for deletion to complete")
        
        sut.deleteItem(item1, from: list) { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, ListError.unableToDeleteItem)
            } else {
                XCTFail("Expected unableToDeleteItem error, got \(result) instead")
            }
            exp.fulfill()
        }
        
        listsStoreSpy.completeWithAnyCacheUpdateError()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_deleteItem_deliversItemsFromCacheOnSuccessfulDeletion() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let item1 = Item(id: UUID(), text: "Item 1")
        let item2 = Item(id: UUID(), text: "Item 2")
        let list = List(id: UUID(), name: "My List", items: [item1, item2])
        
        let listToReturnFromCache = List(id: UUID(), name: "From cache", items: [])
        
        let exp = expectation(description: "Wait for delete to finish")
        
        sut.deleteItem(item2, from: list) { result in
            if case let .success(receivedLists) = result {
                XCTAssertEqual(receivedLists, [listToReturnFromCache])
            } else {
                XCTFail("Expected \(listToReturnFromCache), got \(result) instead")
            }
            exp.fulfill()
        }
        
        listsStoreSpy.completeDeletion(with: [listToReturnFromCache])
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_add_forwardsAppendMessageToCache() {
        let (listsStoreSpy, sut) = makeSUT()
        
        sut.add([anyList()]) { _ in }
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [.append])
    }
    
    func test_addItem_deliversListNotFoundErrorOnCacheError() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let list = anyList()
        let item = Item(id: UUID(), text: "Item 1")
        
        let exp = expectation(description: "Wait for addItem to finish")
        
        sut.addItem(item, to: list) { error in
            XCTAssertEqual(error, .listNotFound)
            
            exp.fulfill()
        }
        
        listsStoreSpy.completeWithAnyCacheUpdateError()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_addItem_updatesListInCache() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let list = anyList()
        let item = Item(id: UUID(), text: "Item 1")
        
        sut.add([list]) { _ in }
        sut.addItem(item, to: list) { _ in }
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [.append, .update])
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (listsStoreSpy: ListsStoreSpy, sut: LocalListsManager) {
        let listsStoreSpy = ListsStoreSpy()
        let sut = LocalListsManager(store: listsStoreSpy)
        
        return (listsStoreSpy, sut)
    }
    
    private func expect(_ sut: LocalListsManager, toCompleteWith expectedResult: Result<[List], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load to complete")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedLists), .success(expectedLists)):
                XCTAssertEqual(receivedLists, expectedLists, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result: \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private class ListsStoreSpy: ListsStore {
        
        enum Message {
            case retrieve
            case append
            case delete
            case update
        }
        
        var completions: [(Result<[List], Error>) -> Void] = []
        var updateCompletions: [(Result<[List], UpdateError>) -> Void] = []
        var receivedMessages: [Message] = []
        
        func retrieve(completion: @escaping (Result<[List], Error>) -> Void) {
            receivedMessages.append(.retrieve)
            completions.append(completion)
        }
        
        func complete(with lists: [List]) {
            completions[0](.success(lists))
        }
        
        func complete(with error: Error) {
            completions[0](.failure(error))
        }
        
        func update(_ list: List, updatedList: List, completion: @escaping (Result<[List], UpdateError>) -> Void) {
            receivedMessages.append(.update)
            updateCompletions.append(completion)
        }
        
        func completeDeletion(with lists: [List]) {
            updateCompletions[0](.success(lists))
        }
        
        func completeWithAnyCacheUpdateError() {
            updateCompletions[0](.failure(.couldNotSaveCache))
        }
        
        func append(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
            receivedMessages.append(.append)
        }
        
        func delete(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
            receivedMessages.append(.delete)
            completions.append(completion)
        }
        
    }
    
}
