//
//  CodableListsStoreTests.swift
//  ShufflerTests
//
//  Created by Suhayl Ahmed on 20/01/2022.
//

import XCTest
import Shuffler

final class CodableListsStore: ListsStore {
    
    private struct Cache: Codable {
        let codableLists: [CodableList]
        
        var modelLists: [List] {
            codableLists.map({ $0.modelList })
        }
    }
    
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
    
    private let storeUrl: URL
    
    init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    
    func retrieve(completion: @escaping (Result<[List], Error>) -> Void) {
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
    
    func insert(_ lists: [List], completion: @escaping ((Result<[List], Error>) -> Void)) {
        retrieve { result in
            switch result {
            case let .success(cachedLists):
                let updatedLists = cachedLists + lists
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
        
        expect(sut, toRetrieve: .success([])) { }
    }
    
    func test_insert_returnsInsertedListOnEmptyCache() {
        let sut = makeSUT()
        
        let lists: [List] = [anyList(), anyList()]
        
        expectInsert(lists, intoSUT: sut, toCompleteWith: .success(lists)) { }
    }
    
    func test_retrieve_deliversValuesOnNonEmptyCache() {
        let sut = makeSUT()
        
        let lists: [List] = [anyList(), anyList()]
        expectInsert(lists, intoSUT: sut, toCompleteWith: .success(lists)) { }
        expect(sut, toRetrieve: .success(lists)) { }
    }
    
    func test_insertTwice_appendsTheListsToTheCurrentCache() {
        let sut = makeSUT()
        
        let lists1 = [anyList(), anyList()]
        let lists2 = [anyList(), anyList(), anyList()]
        
        sut.insert(lists1) { _ in }
        sut.insert(lists2) { _ in }
        
        expect(sut, toRetrieve: .success(lists1 + lists2)) { }
    }
    
    // MARK: - Helpers
    private func makeSUT() -> CodableListsStore {
        let sut = CodableListsStore(storeUrl: testStoreUrl())
        
        return sut
    }
    
    private func expect(_ sut: CodableListsStore, toRetrieve expectedResult: Result<[List], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
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
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectInsert(_ lists: [List], intoSUT sut: CodableListsStore, toCompleteWith expectedResult: Result<[List], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for insertion to finish")
        
        sut.insert(lists) { receivedResult in
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
