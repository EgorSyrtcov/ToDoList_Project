//
//  SceneDelegate.swift
//  ToDoList_Project
//
//  Created by Egor Syrtcov on 22.08.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let appCoordinator = AppCoordinator(window: window)
        appCoordinator.start()
        
        self.appCoordinator = appCoordinator
        window.makeKeyAndVisible()
    }
}

