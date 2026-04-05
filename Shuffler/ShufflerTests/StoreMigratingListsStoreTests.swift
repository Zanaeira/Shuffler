//
//  StoreMigratingListsStoreTests.swift
//  ShufflerTests
//
//  Created by Suhayl Ahmed on 05/04/2026.
//

import XCTest
import Shuffler

class StoreMigratingListsStoreTests: XCTestCase {

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

		expect(sut, toRetrieve: .success([]))
	}

	// MARK: - Helpers

	private func makeSUT() -> StoreMigratingListsStore {
		let primaryListsStore = CodableListsStore(storeUrl: testStoreUrl(.documentDirectory))
		let fallbackListsStoreToMigrateFrom = CodableListsStore(storeUrl: testStoreUrl(.cachesDirectory))
		let sut = StoreMigratingListsStore(primaryListsStore: primaryListsStore, fallbackListsStoreToMigrateFrom: fallbackListsStoreToMigrateFrom)

		return sut
	}

	private func testStoreUrl(_ path: FileManager.SearchPathDirectory) -> URL {
		let cachesDirectory = FileManager.default.urls(for: path, in: .userDomainMask).first
		let storeUrl = cachesDirectory?.appendingPathComponent("\(type(of: self)).store")

		return storeUrl!
	}

	private func expect(_ sut: StoreMigratingListsStore, toRetrieve expectedResult: Result<[List], Error>, file: StaticString = #filePath, line: UInt = #line) {
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

}

class StoreMigratingListsStore: ListsStore {

	private let primaryListsStore: ListsStore
	private let fallbackListsStoreToMigrateFrom: ListsStore

	init(primaryListsStore: ListsStore, fallbackListsStoreToMigrateFrom: ListsStore) {
		self.primaryListsStore = primaryListsStore
		self.fallbackListsStoreToMigrateFrom = fallbackListsStoreToMigrateFrom
	}

	func retrieve(completion: @escaping (Result<[Shuffler.List], Shuffler.ListError>) -> Void) {
		primaryListsStore.retrieve(completion: completion)
	}

	func insert(_ lists: [Shuffler.List], completion: @escaping (Result<[Shuffler.List], Shuffler.ListError>) -> Void) {

	}

	func update(_ list: Shuffler.List, updatedList: Shuffler.List, completion: @escaping (Result<[Shuffler.List], Shuffler.UpdateError>) -> Void) {

	}

	func append(_ lists: [Shuffler.List], completion: @escaping (Result<[Shuffler.List], Shuffler.ListError>) -> Void) {

	}

	func delete(_ lists: [Shuffler.List], completion: @escaping (Result<[Shuffler.List], Shuffler.ListError>) -> Void) {

	}


}
