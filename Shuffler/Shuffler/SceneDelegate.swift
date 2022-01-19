//
//  SceneDelegate.swift
//  Shuffler
//
//  Created by Suhayl Ahmed on 17/01/2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let listLoader = LocalListLoader()
        let listsCoordinator = ListsCoordinator(listLoader: listLoader, listUpdater: listLoader)
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = listsCoordinator.navigationController
        window?.makeKeyAndVisible()
    }
    
}
