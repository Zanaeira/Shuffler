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

class StoreMigratingListsStore: ListsStore {

	private let primaryListsStore: ListsStore
	private let fallbackListsStoreToMigrateFrom: ListsStore

	init(primaryListsStore: ListsStore, fallbackListsStoreToMigrateFrom: ListsStore) {
		self.primaryListsStore = primaryListsStore
		self.fallbackListsStoreToMigrateFrom = fallbackListsStoreToMigrateFrom
	}

	func retrieve(completion: @escaping (Result<[Shuffler.List], Shuffler.ListError>) -> Void) {
		primaryListsStore.retrieve { [weak self] result in
			switch result {
			case .success(let lists):
				if lists.isEmpty {
					self?.fallbackListsStoreToMigrateFrom.retrieve { [weak self] result in
						switch result {
						case .success(let lists):
							if !lists.isEmpty {
								self?.primaryListsStore.append(lists) { result in
									switch result {
									case .success(let lists): completion(.success(lists))
									case .failure(let error): completion(.failure(error))
									}
								}
							} else {
								completion(.success([]))
							}
						case .failure(let error): completion(.failure(error))
						}
					}
				} else {
					completion(.success(lists))
				}
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	func insert(_ lists: [Shuffler.List], completion: @escaping (Result<[Shuffler.List], Shuffler.ListError>) -> Void) {

	}

	func update(_ list: Shuffler.List, updatedList: Shuffler.List, completion: @escaping (Result<[Shuffler.List], Shuffler.UpdateError>) -> Void) {

	}

	func append(_ lists: [Shuffler.List], completion: @escaping (Result<[Shuffler.List], Shuffler.ListError>) -> Void) {
		primaryListsStore.append(lists, completion: completion)
	}

	func delete(_ lists: [Shuffler.List], completion: @escaping (Result<[Shuffler.List], Shuffler.ListError>) -> Void) {

	}

}
