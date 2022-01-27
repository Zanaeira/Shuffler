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
        
        let storeUrl = getStoreUrl()
        let codableListsStore = CodableListsStore(storeUrl: storeUrl)
        let localListsManager = LocalListsManager(store: codableListsStore)
        
        let listsNavigator = ListsNavigator(listsManager: localListsManager)
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = listsNavigator.navigationController
        window?.makeKeyAndVisible()
    }
    
    private func getStoreUrl() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        
        return documentsDirectory.appendingPathComponent("lists.store")
    }
    
}
