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
		let sut = makeSUT()

		expect(sut, toRetrieve: .success([]))
	}

	func test_retrieve_deliversValuesOnNonEmptyCache() {
		let sut = makeSUT()

		let lists: [List] = [anyList(), anyList()]

		sut.append(lists) { _ in }

		expect(sut, toRetrieve: .success(lists))
	}

	func test_retrieve_deliversValuesFromPrimaryListsStore() {
		let primaryListsStore = CodableListsStore(storeUrl: testStoreUrl(.documentDirectory))
		let fallbackListsStoreToMigrateFrom = CodableListsStore(storeUrl: testStoreUrl(.cachesDirectory))
		let lists: [List] = [anyList(), anyList()]
		primaryListsStore.append(lists) { _ in }

		let sut = StoreMigratingListsStore(primaryListsStore: primaryListsStore, fallbackListsStoreToMigrateFrom: fallbackListsStoreToMigrateFrom)

		expect(sut, toRetrieve: .success(lists))
	}

	func test_retrieve_deliversValuesOnEmptyCacheWithNonEmptyFallback() {
		let primaryListsStore = CodableListsStore(storeUrl: testStoreUrl(.documentDirectory))
		let fallbackListsStoreToMigrateFrom = CodableListsStore(storeUrl: testStoreUrl(.cachesDirectory))
		let lists: [List] = [anyList(), anyList()]
		fallbackListsStoreToMigrateFrom.append(lists) { _ in }

		let sut = StoreMigratingListsStore(primaryListsStore: primaryListsStore, fallbackListsStoreToMigrateFrom: fallbackListsStoreToMigrateFrom)

		expect(sut, toRetrieve: .success(lists))
	}

	func test_retrieve_migratesValuesOnEmptyCacheWithNonEmptyFallback() {
		let primaryListsStore = CodableListsStore(storeUrl: testStoreUrl(.documentDirectory))
		let fallbackListsStoreToMigrateFrom = CodableListsStore(storeUrl: testStoreUrl(.cachesDirectory))
		let lists: [List] = [anyList(), anyList()]
		fallbackListsStoreToMigrateFrom.append(lists) { _ in }

		let sut = StoreMigratingListsStore(primaryListsStore: primaryListsStore, fallbackListsStoreToMigrateFrom: fallbackListsStoreToMigrateFrom)

		expect(sut, toRetrieve: .success(lists))
		expect(primaryListsStore, toRetrieve: .success(lists))
		expect(fallbackListsStoreToMigrateFrom, toRetrieve: .success([]))
	}

	func test_retrieve_migratesValuesOnEmptyCacheWithNonEmptyFallbackOnlyOnce() {
		let primaryListsStore = CodableListsStore(storeUrl: testStoreUrl(.documentDirectory))
		let fallbackListsStoreToMigrateFrom = CodableListsStore(storeUrl: testStoreUrl(.cachesDirectory))
		let lists: [List] = [anyList(), anyList()]
		fallbackListsStoreToMigrateFrom.append(lists) { _ in }

		let sut = StoreMigratingListsStore(primaryListsStore: primaryListsStore, fallbackListsStoreToMigrateFrom: fallbackListsStoreToMigrateFrom)

		expect(sut, toRetrieve: .success(lists))
		expect(sut, toRetrieve: .success(lists))
		expect(primaryListsStore, toRetrieve: .success(lists))
	}

	func test_retrieve_migratesNewFallbackValuesToNonEmptyPrimaryStore() {
		let primaryListsStore = CodableListsStore(storeUrl: testStoreUrl(.documentDirectory))
		let fallbackListsStoreToMigrateFrom = CodableListsStore(storeUrl: testStoreUrl(.cachesDirectory))
		let lists: [List] = [anyList(), anyList(), anyList()]
		let lists2: [List] = [anyList(), anyList(), anyList(), anyList()]
		primaryListsStore.append(lists) { _ in }
		fallbackListsStoreToMigrateFrom.append(lists2) { _ in }

		let sut = StoreMigratingListsStore(primaryListsStore: primaryListsStore, fallbackListsStoreToMigrateFrom: fallbackListsStoreToMigrateFrom)

		expect(sut, toRetrieve: .success(lists + lists2))
		expect(primaryListsStore, toRetrieve: .success(lists + lists2))
		expect(fallbackListsStoreToMigrateFrom, toRetrieve: .success([]))
	}

	func test_insert_forwardsMessageToPrimaryStoreOnly() {
		let primaryListsStore = CodableListsStore(storeUrl: testStoreUrl(.documentDirectory))
		let fallbackListsStore = CodableListsStore(storeUrl: testStoreUrl(.cachesDirectory))
		let lists: [List] = [anyList(), anyList()]
		let sut = StoreMigratingListsStore(primaryListsStore: primaryListsStore, fallbackListsStoreToMigrateFrom: fallbackListsStore)

		sut.insert(lists) { _ in }

		expect(sut, toRetrieve: .success(lists))
		expect(primaryListsStore, toRetrieve: .success(lists))
		expect(fallbackListsStore, toRetrieve: .success([]))
	}

	func test_append_forwardsMessageToPrimaryStoreOnly() {
		let primaryListsStore = CodableListsStore(storeUrl: testStoreUrl(.documentDirectory))
		let fallbackListsStore = CodableListsStore(storeUrl: testStoreUrl(.cachesDirectory))
		let lists: [List] = [anyList(), anyList()]
		let sut = StoreMigratingListsStore(primaryListsStore: primaryListsStore, fallbackListsStoreToMigrateFrom: fallbackListsStore)

		sut.append(lists) { _ in }

		expect(sut, toRetrieve: .success(lists))
		expect(primaryListsStore, toRetrieve: .success(lists))
		expect(fallbackListsStore, toRetrieve: .success([]))
	}

	func test_update_forwardsMessageToPrimaryStoreOnly() {
		let primaryListsStore = CodableListsStore(storeUrl: testStoreUrl(.documentDirectory))
		let fallbackListsStore = CodableListsStore(storeUrl: testStoreUrl(.cachesDirectory))
		let list = anyList()
		let updatedList = anyList()
		let sut = StoreMigratingListsStore(primaryListsStore: primaryListsStore, fallbackListsStoreToMigrateFrom: fallbackListsStore)
		sut.insert([list]) { _ in }

		sut.update(list, updatedList: updatedList) { _ in }

		expect(sut, toRetrieve: .success([updatedList]))
		expect(primaryListsStore, toRetrieve: .success([updatedList]))
		expect(fallbackListsStore, toRetrieve: .success([]))
	}

	func test_delete_forwardsMessageToBothStores() {
		let primaryListsStore = CodableListsStore(storeUrl: testStoreUrl(.documentDirectory))
		let fallbackListsStore = CodableListsStore(storeUrl: testStoreUrl(.cachesDirectory))
		let listToDelete = anyList()
		let listToSave = anyList()
		let sut = StoreMigratingListsStore(primaryListsStore: primaryListsStore, fallbackListsStoreToMigrateFrom: fallbackListsStore)

		primaryListsStore.insert([listToSave, listToDelete]) { _ in }
		fallbackListsStore.insert([listToDelete]) { _ in }
		sut.delete([listToDelete]) { _ in }

		expect(sut, toRetrieve: .success([listToSave]))
		expect(primaryListsStore, toRetrieve: .success([listToSave]))
		expect(fallbackListsStore, toRetrieve: .success([]))
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
