//
//  SceneDelegate.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UIGestureRecognizerDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        if connectionOptions.urlContexts.first?.url != nil {
            guard
                let host = connectionOptions.urlContexts.first?.url.host,
                let path = connectionOptions.urlContexts.first?.url.path,
                host == "firebasestorage.googleapis.com" else  { return }
            
            openPhotoScreen(deepLinkPath: path)
            return
        }
        let navigation = UINavigationController()
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
        if let _ = SecureStorageService.shared.obtainToken() {
            let coordinator = MapCoordinator(rootNavigationController: navigation)
            coordinator.start()
        } else {
            let coordinator = AuthCoordinator(rootNavigationController: navigation)
            coordinator.start()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard
            let host = URLContexts.first?.url.host,
            let path = URLContexts.first?.url.path,
            host == "firebasestorage.googleapis.com" else  { return }
        
        openPhotoScreen(deepLinkPath: path)
    }
    
    private func openPhotoScreen(deepLinkPath: String) {
        let navigation = UINavigationController()
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
        DeepLinkService.path = deepLinkPath
        DeepLinkService.shared.openPhotoWith(navigationController: navigation)
    }


}

