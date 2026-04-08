//
//  SceneDelegate.swift
//  ShufflerApp
//
//  Created by Suhayl Ahmed on 26/01/2022.
//

import UIKit
import Shuffler
import ShuffleriOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		let legacyStore = CodableListsStore(storeUrl: getLegacyStoreUrl())
		let store = CodableListsStore(storeUrl: getStoreUrl())
		let listsStore = StoreMigratingListsStore(primaryListsStore: store, fallbackListsStoreToMigrateFrom: legacyStore)
		let localListsManager = LocalListsManager(store: listsStore)

		let listsNavigator = ListsNavigator(listsManager: localListsManager)

		window = UIWindow(frame: windowScene.coordinateSpace.bounds)
		window?.windowScene = windowScene
		window?.rootViewController = listsNavigator.navigationController
		window?.makeKeyAndVisible()
	}

	private func getStoreUrl() -> URL {
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		return documentsDirectory.appendingPathComponent("lists.store")
	}

	private func getLegacyStoreUrl() -> URL {
		let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
		return cachesDirectory.appendingPathComponent("lists.store")
	}

}
