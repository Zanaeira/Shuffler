//
//  CodableListsStoreTests.swift
//  ShufflerTests
//
//  Created by Suhayl Ahmed on 20/01/2022.
//

import XCTest
import Shuffler

class CodableListsStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(at: testStoreUrl())
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? FileManager.default.removeItem(at: testStoreUrl())
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .success([]))
    }
    
    func test_retrieveTwice_hasNoSideEffectsAndDeliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .success([]))
    }
    
    func test_insert_deliversCouldNotInsertListsErrorForInvalidStoreURL() {
        let sut = CodableListsStore(storeUrl: URL(string: "www.invalid-url.com")!)
        
        let list = anyList()
        
        let exp = expectation(description: "Wait for insert to finish")
        sut.insert([list]) { result in
            switch result {
            case .success:
                XCTFail("Expected couldNotInsertLists, got \(result) instead")
            case let .failure(error):
                XCTAssertEqual(error, .couldNotInsertLists)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_insert_deliversValuesOnValidStoreURL() {
        let sut = makeSUT()
        
        let list = anyList()
        
        let exp = expectation(description: "Wait for insert to finish")
        sut.insert([list]) { result in
            switch result {
            case let .success(lists):
                XCTAssertEqual(lists, [list])
            case .failure:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_append_returnsAppendedListOnEmptyCache() {
        let sut = makeSUT()
        
        let lists: [List] = [anyList(), anyList()]
        
        let exp = expectation(description: "Wait for append to finish")
        sut.append(lists) { result in
            if case .success(let receivedLists) = result {
                XCTAssertEqual(lists, receivedLists)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_deliversValuesOnNonEmptyCache() {
        let sut = makeSUT()
        
        let lists: [List] = [anyList(), anyList()]
        
        sut.append(lists) { _ in }
        
        expect(sut, toRetrieve: .success(lists))
        
    }
    
    func test_retrieveTwice_deliversSameValuesOnNonEmptyCache() {
        let sut = makeSUT()
        
        let lists: [List] = [anyList(), anyList()]
        
        sut.append(lists) { _ in }
        
        expect(sut, toRetrieve: .success(lists))
        expect(sut, toRetrieve: .success(lists))
    }
    
    func test_appendTwice_appendsTheListsToTheCurrentCache() {
        let sut = makeSUT()
        
        let lists1 = [anyList(), anyList()]
        let lists2 = [anyList(), anyList(), anyList()]
        
        sut.append(lists1) { _ in }
        sut.append(lists2) { _ in }
        
        expect(sut, toRetrieve: .success(lists1 + lists2))
    }
    
    func test_append_onlyAppendsListsWithUniqueIDNotInCacheAndIgnoresListsWithIDAlreadyInCache() {
        let sut = makeSUT()
        
        let list1 = anyList()
        let list2 = anyList()
        let list3 = anyList()
        
        sut.append([list1, list2]) { _ in }
        
        let exp = expectation(description: "Wait for append to finish")
        sut.append([list1, list3]) { result in
            switch result {
            case let .success(receivedLists):
                XCTAssertEqual(receivedLists, [list1, list2, list3])
            case .failure:
                XCTFail("Expected success with [list, list2], got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_delete_completesWithEmptyListOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for delete to finish")
        
        sut.delete([anyList()]) { result in
            if case .success(let lists) = result {
                XCTAssertEqual(lists, [])
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        sut.delete([anyList()]) { _ in }
        expect(sut, toRetrieve: .success([]))
    }
    
    func test_delete_removesLastListOnNonEmptyCache() {
        let sut = makeSUT()
        
        let list = anyList()
        let list2 = anyList()
        
        sut.append([list, list2]) { _ in }
        sut.delete([list2]) { _ in }
        
        expect(sut, toRetrieve: .success([list]))
    }
    
    func test_delete_removesSpecificListOnNonEmptyCache() {
        let sut = makeSUT()
        
        let list1 = anyList()
        let list2 = anyList()
        let list3 = anyList()
        let list4 = anyList()
        let list5 = anyList()
        
        sut.append([list1, list2, list3, list4, list5]) { _ in }
        sut.delete([list3]) { _ in }
        
        expect(sut, toRetrieve: .success([list1, list2, list4, list5]))
    }
    
    func test_delete_removesMultipleListsOnNonEmptyCache() {
        let sut = makeSUT()
        
        let list1 = anyList()
        let list2 = anyList()
        let list3 = anyList()
        let list4 = anyList()
        let list5 = anyList()
        
        sut.append([list1, list2, list3, list4, list5]) { _ in }
        sut.delete([list1, list3, list5]) { _ in }
        
        expect(sut, toRetrieve: .success([list2, list4]))
    }
    
    func test_update_doesNothingOnEmptyCache() {
        let sut = makeSUT()
        
        let (list, updatedList) = listAndUpdatedList()
        
        sut.update(list, updatedList: updatedList) { _ in }
        
        expect(sut, toRetrieve: .success([]))
    }
    
    func test_update_deliversErrorOnUpdatingListThatIsNotInCache() {
        let sut = makeSUT()
        
        let (list, updatedList) = listAndUpdatedList()
        
        sut.append([anyList()]) { _ in }
        
        let exp = expectation(description: "Wait for update to complete")
        
        sut.update(list, updatedList: updatedList) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error, .listNotFound)
            } else {
                XCTFail("Expected .listNotFound UpdateError, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_update_deliversUpdatedListIfListFoundInCache() {
        let sut = makeSUT()
        
        let (list, updatedList) = listAndUpdatedList()
        
        sut.append([list]) { _ in }
        
        let exp = expectation(description: "Wait for update to complete")
        
        sut.update(list, updatedList: updatedList) { result in
            if case .success(let receivedLists) = result {
                XCTAssertEqual(receivedLists, [updatedList])
            } else {
                XCTFail("Expected \(updatedList), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_update_updatesListInCacheIfListFoundInCache() {
        let sut = makeSUT()
        
        let (list, updatedList) = listAndUpdatedList()
        
        sut.append([list]) { _ in }
        sut.update(list, updatedList: updatedList) { _ in }
        
        expect(sut, toRetrieve: .success([updatedList]))
    }
    
    // MARK: - Helpers
    private func makeSUT() -> CodableListsStore {
        let sut = CodableListsStore(storeUrl: testStoreUrl())
        
        return sut
    }
    
    private func listAndUpdatedList() -> (list: List, updatedList: List) {
        let items: [Item] = [
            .init(id: UUID(), text: "Item 1"),
            .init(id: UUID(), text: "Item 2")
        ]
        let list = List(id: UUID(), name: "My List", items: items)
        
        let updatedItems: [Item] = [items.first!]
        let updatedList = List(id: list.id, name: list.name, items: updatedItems)
        
        return (list, updatedList)
    }
    
    private func expect(_ sut: CodableListsStore, toRetrieve expectedResult: Result<[List], Error>, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load to complete")
        
        sut.retrieve { receivedResult in
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
        
        wait(for: [exp], timeout: 1.0)
    }
        
    private func testStoreUrl() -> URL {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let storeUrl = cachesDirectory?.appendingPathComponent("\(type(of: self)).store")
        
        return storeUrl!
    }
    
}
