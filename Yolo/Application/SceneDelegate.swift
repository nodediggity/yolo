//
//  SceneDelegate.swift
//  Yolo
//
//  Created by Gordon Smith on 28/04/2021.
//

import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var baseURL = URL(string: "https://powerful-wave-91495.herokuapp.com/")!
    
    convenience init(httpClient: HTTPClient) {
        self.init()
        self.httpClient = httpClient
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let scene = (scene as? UIWindowScene) {
            configure(window: .init(windowScene: scene))
        }
    }
    
    func configure(window: UIWindow) {
        window.rootViewController = FeedUIComposer.compose(
            loader: makeRemoteFeedLoader,
            imageLoader: { _ in PassthroughSubject<Data, Error>().eraseToAnyPublisher() }
        )
        
        window.makeKeyAndVisible()
        self.window = window
    }
}

private extension SceneDelegate {
    
    func makeRemoteFeedLoader() -> AnyPublisher<[FeedItem], Error> {
        let request = URLRequest(url: baseURL.appendingPathComponent("feed"))
        return httpClient
            .dispatchPublisher(for: request)
            .tryMap(FeedResponseMapper.map)
            .map { $0.items }
            .eraseToAnyPublisher()
    }
}
