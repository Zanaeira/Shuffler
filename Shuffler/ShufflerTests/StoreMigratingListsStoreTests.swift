//
//  StoreMigratingListsStoreTests.swift
//  ShufflerTests
//
//  Created by Suhayl Ahmed on 05/04/2026.
//

import XCTest
import Shuffler

class StoreMigratingListsStoreTests: XCTestCase {

	override func setUp() {
		super.setUp()

		try? FileManager.default.removeItem(at: testStoreUrl(.documentDirectory))
		try? FileManager.default.removeItem(at: testStoreUrl(.cachesDirectory))
	}

	override func tearDown() {
		super.tearDown()

		try? FileManager.default.removeItem(at: testStoreUrl(.documentDirectory))
		try? FileManager.default.removeItem(at: testStoreUrl(.cachesDirectory))
	}

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let (sut, _, _) = makeSUT()

		expect(sut, toRetrieve: .success([]))
	}

	func test_retrieve_deliversValuesOnNonEmptyCache() {
		let (sut, _, _) = makeSUT()

		let lists: [List] = [anyList(), anyList()]

		sut.append(lists) { _ in }

		expect(sut, toRetrieve: .success(lists))
	}

	func test_retrieve_deliversValuesFromPrimaryListsStore() {
		let (sut, primaryStore, _) = makeSUT()
		let lists: [List] = [anyList(), anyList()]
		primaryStore.append(lists) { _ in }

		expect(sut, toRetrieve: .success(lists))
	}

	func test_retrieve_deliversValuesOnEmptyCacheWithNonEmptyFallback() {
		let (sut, _, fallbackStore) = makeSUT()
		let lists: [List] = [anyList(), anyList()]
		fallbackStore.append(lists) { _ in }

		expect(sut, toRetrieve: .success(lists))
	}

	func test_retrieve_migratesValuesOnEmptyCacheWithNonEmptyFallback() {
		let (sut, primaryStore, fallbackStore) = makeSUT()
		let lists: [List] = [anyList(), anyList()]
		fallbackStore.append(lists) { _ in }

		expect(sut, toRetrieve: .success(lists))
		expect(primaryStore, toRetrieve: .success(lists))
		expect(fallbackStore, toRetrieve: .success([]))
	}

	func test_retrieve_migratesValuesOnEmptyCacheWithNonEmptyFallbackOnlyOnce() {
		let (sut, primaryStore, fallbackStore) = makeSUT()
		let lists: [List] = [anyList(), anyList()]
		fallbackStore.append(lists) { _ in }

		expect(sut, toRetrieve: .success(lists))
		expect(sut, toRetrieve: .success(lists))
		expect(primaryStore, toRetrieve: .success(lists))
	}

	func test_retrieve_migratesNewFallbackValuesToNonEmptyPrimaryStore() {
		let (sut, primaryStore, fallbackStore) = makeSUT()
		let lists: [List] = [anyList(), anyList(), anyList()]
		let lists2: [List] = [anyList(), anyList(), anyList(), anyList()]
		primaryStore.append(lists) { _ in }
		fallbackStore.append(lists2) { _ in }

		expect(sut, toRetrieve: .success(lists + lists2))
		expect(primaryStore, toRetrieve: .success(lists + lists2))
		expect(fallbackStore, toRetrieve: .success([]))
	}

	func test_insert_forwardsMessageToPrimaryStoreOnly() {
		let (sut, primaryStore, fallbackStore) = makeSUT()
		let lists: [List] = [anyList(), anyList()]

		sut.insert(lists) { _ in }

		expect(sut, toRetrieve: .success(lists))
		expect(primaryStore, toRetrieve: .success(lists))
		expect(fallbackStore, toRetrieve: .success([]))
	}

	func test_append_forwardsMessageToPrimaryStoreOnly() {
		let (sut, primaryStore, fallbackStore) = makeSUT()
		let lists: [List] = [anyList(), anyList()]

		sut.append(lists) { _ in }

		expect(sut, toRetrieve: .success(lists))
		expect(primaryStore, toRetrieve: .success(lists))
		expect(fallbackStore, toRetrieve: .success([]))
	}

	func test_update_forwardsMessageToPrimaryStoreOnly() {
		let (sut, primaryStore, fallbackStore) = makeSUT()
		let list = anyList()
		let updatedList = anyList()
		sut.insert([list]) { _ in }

		sut.update(list, updatedList: updatedList) { _ in }

		expect(sut, toRetrieve: .success([updatedList]))
		expect(primaryStore, toRetrieve: .success([updatedList]))
		expect(fallbackStore, toRetrieve: .success([]))
	}

	func test_delete_forwardsMessageToBothStores() {
		let (sut, primaryStore, fallbackStore) = makeSUT()
		let listToDelete = anyList()
		let listToSave = anyList()

		primaryStore.insert([listToSave, listToDelete]) { _ in }
		fallbackStore.insert([listToDelete]) { _ in }
		sut.delete([listToDelete]) { _ in }

		expect(sut, toRetrieve: .success([listToSave]))
		expect(primaryStore, toRetrieve: .success([listToSave]))
		expect(fallbackStore, toRetrieve: .success([]))
	}

	// MARK: - Helpers

	private func makeSUT() -> (sut: StoreMigratingListsStore, primaryStore: ListsStore, fallbackStore: ListsStore) {
		let primaryListsStore = CodableListsStore(storeUrl: testStoreUrl(.documentDirectory))
		let fallbackListsStoreToMigrateFrom = CodableListsStore(storeUrl: testStoreUrl(.cachesDirectory))
		let sut = StoreMigratingListsStore(primaryListsStore: primaryListsStore, fallbackListsStoreToMigrateFrom: fallbackListsStoreToMigrateFrom)

		return (sut, primaryListsStore, fallbackListsStoreToMigrateFrom)
	}

	private func testStoreUrl(_ path: FileManager.SearchPathDirectory) -> URL {
		let cachesDirectory = FileManager.default.urls(for: path, in: .userDomainMask).first
		let storeUrl = cachesDirectory?.appendingPathComponent("\(type(of: self)).store")

		return storeUrl!
	}

	private func expect(_ sut: ListsStore, toRetrieve expectedResult: Result<[List], Error>, file: StaticString = #filePath, line: UInt = #line) {
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
