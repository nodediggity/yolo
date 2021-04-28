//
//  SceneDelegate.swift
//  Yolo
//
//  Created by Gordon Smith on 28/04/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let scene = (scene as? UIWindowScene) {
            let window = UIWindow(windowScene: scene)
            window.rootViewController = .init()
            window.makeKeyAndVisible()
            self.window = window
        }
    }
}

