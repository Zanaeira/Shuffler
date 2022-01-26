//
//  LocalListsManagerTests.swift
//  ShufflerTests
//
//  Created by Suhayl Ahmed on 22/01/2022.
//

import XCTest
import Shuffler

class LocalListsManagerTests: XCTestCase {
    
    func test_init_doesNotMessageCache() {
        let (listsStoreSpy, _) = makeSUT()
        
        XCTAssertEqual(listsStoreSpy.receivedMessages, [])
    }
    
    func test_load_onEmptyCacheReturnsEmptyLists() {
        let (listsStoreSpy, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            listsStoreSpy.completeRetrieve(with: [])
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
            listsStoreSpy.completeRetrieve(with: [list])
        }
    }
    
    func test_load_deliversErrorOnCacheError() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let error = anyError()
        
        expect(sut, toCompleteWith: .failure(error)) {
            listsStoreSpy.completeRetrieve(with: error)
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
        
        listsStoreSpy.completeRetrieve(with: ListError.listNotFound)
        
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
        
        listsStoreSpy.completeRetrieve(with: [list2, list3])
        
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
        
        sut.addItem(item, to: list) { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, .listNotFound)
            } else {
                XCTFail("Expected listNotFound error, got \(result) instead")
            }
            exp.fulfill()
        }
        
        listsStoreSpy.completeUpdate(with: .listNotFound)
        
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
    
    func test_addItem_deliversListsFromCacheOnSuccess() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let list = anyList()
        let item = Item(id: UUID(), text: "Item 1")
        
        let expectedList = List(id: list.id, name: list.name, items: [item])
        
        let exp = expectation(description: "Wait for addItem to finish")
        
        sut.addItem(item, to: list) { result in
            if case let .success(lists) = result {
                XCTAssertEqual(lists, [expectedList])
            } else {
                XCTFail("Expected [\(expectedList)], got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        listsStoreSpy.completeUpdate(with: [expectedList])
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_addItem_sendsCorrectListsToCacheUpdateCall() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let list = anyList()
        let item = Item(id: UUID(), text: "Item 1")
        
        let expectedList = List(id: list.id, name: list.name, items: [item])
        
        sut.addItem(item, to: list) { _ in }
        
        XCTAssertEqual(list, listsStoreSpy.list1ToUpdate)
        XCTAssertEqual(expectedList, listsStoreSpy.list2ToUpdate)
    }
    
    func test_addItem_appendsNewItemToListItemsInsteadOfOverwritingItems() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let item = Item(id: UUID(), text: "Item 1")
        let list = List(id: UUID(), name: "My List", items: [item])
        
        let newItem = Item(id: UUID(), text: "Item 2")
        
        let expectedList = List(id: list.id, name: list.name, items: [item, newItem])
        
        sut.addItem(newItem, to: list) { _ in }
        
        XCTAssertEqual(list, listsStoreSpy.list1ToUpdate)
        XCTAssertEqual(expectedList, listsStoreSpy.list2ToUpdate)
    }
    
    func test_addItem_deliversUnableToAddItemErrorOnOtherThanListNotFoundError() {
        let (listsStoreSpy, sut) = makeSUT()
        
        let item = Item(id: UUID(), text: "Item 1")
        let list = List(id: UUID(), name: "My List", items: [item])
        
        sut.add([list]) { _ in }
        
        let exp = expectation(description: "Wait for addItem to finish")
        
        sut.addItem(Item(id: UUID(), text: "New Item"), to: list) { result in
            if case let .failure(error) = result {
                XCTAssertEqual(error, .unableToAddItem)
            } else {
                XCTFail("Expected couldNotRetrieveCache, got \(result) instead")
            }
            exp.fulfill()
        }
        
        listsStoreSpy.completeUpdate(with: .couldNotRetrieveCache)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (listsStoreSpy: ListsStoreSpy, sut: LocalListsManager) {
        let listsStoreSpy = ListsStoreSpy()
        let sut = LocalListsManager(store: listsStoreSpy)
        trackForMemoryLeaks(listsStoreSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (listsStoreSpy, sut)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
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
        var list1ToUpdate: List?
        var list2ToUpdate: List?
        var listsToUpdateAreDifferent: Bool {
            list1ToUpdate != list2ToUpdate
        }
        
        var receivedMessages: [Message] = []
        
        func retrieve(completion: @escaping (Result<[List], Error>) -> Void) {
            receivedMessages.append(.retrieve)
            completions.append(completion)
        }
        
        func completeRetrieve(with lists: [List]) {
            completions[0](.success(lists))
        }
        
        func completeRetrieve(with error: Error) {
            completions[0](.failure(error))
        }
        
        func update(_ list: List, updatedList: List, completion: @escaping (Result<[List], UpdateError>) -> Void) {
            receivedMessages.append(.update)
            updateCompletions.append(completion)
            list1ToUpdate = list
            list2ToUpdate = updatedList
        }
        
        func completeUpdate(with lists: [List]) {
            updateCompletions[0](.success(lists))
        }
        
        func completeUpdate(with error: UpdateError) {
            updateCompletions[0](.failure(error))
        }
        
        func delete(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
            receivedMessages.append(.delete)
            completions.append(completion)
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
        
    }
    
}
