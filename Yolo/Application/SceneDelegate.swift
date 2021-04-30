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
    
    private lazy var navController: UINavigationController = {
        let navController = UINavigationController(rootViewController: makeFeedScene())
        return navController
    }()
    
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
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
    }
}

private extension SceneDelegate {
    
    func makeFeedScene() -> UIViewController {
        FeedUIComposer.compose(
           loader: makeRemoteFeedLoader,
           imageLoader: makeRemoteImageLoader,
            selection: { [self] in showContentScene(id: $0.id) }
       )
    }
    
    func showContentScene(id: String) {
        let loader = makeRemoteContentWithCommentsLoader(id: id)
        let viewController = ContentUIComposer.compose(
            loader: { loader },
            imageLoader: { _ in Empty().eraseToAnyPublisher() }
        )
        navController.pushViewController(viewController, animated: true)
    }
    
    func makeRemoteFeedLoader() -> AnyPublisher<[FeedItem], Error> {
        let request = URLRequest(url: baseURL.appendingPathComponent("feed"))
        return httpClient
            .dispatchPublisher(for: request)
            .tryMap(FeedResponseMapper.map)
            .map { $0.items }
            .eraseToAnyPublisher()
    }
    
    func makeRemoteImageLoader(_ imageURL: URL) -> AnyPublisher<Data, Error> {
        let request = URLRequest(url: imageURL)
        return httpClient
            .dispatchPublisher(for: request)
            .tryMap(ImageResponseMapper.map)
            .eraseToAnyPublisher()
    }
    
    func makeRemoteContentWithCommentsLoader(id: String) -> AnyPublisher<(content: Content, comments: [Comment]), Error> {
        Publishers.Zip(makeRemoteContentLoader(id: id), makeRemoteCommentsLoader(id: id))
            .map(mapContent)
            .eraseToAnyPublisher()
    }
    
    func makeRemoteContentLoader(id: String) -> AnyPublisher<Content, Error> {
        let request = URLRequest(
            url: baseURL
                .appendingPathComponent("content")
                .appendingPathComponent(id)
        )
        return httpClient
            .dispatchPublisher(for: request)
            .tryMap(ContentResponseMapper.map)
            .eraseToAnyPublisher()
    }
    
    func makeRemoteCommentsLoader(id: String) -> AnyPublisher<[Comment], Error> {
        let request = URLRequest(
            url: baseURL
                .appendingPathComponent("comments")
                .appendingPathComponent(id)
        )
        return httpClient
            .dispatchPublisher(for: request)
            .tryMap(CommentsResponseMapper.map)
            .eraseToAnyPublisher()
    }
    
    func mapContent(_ values: (Content, [Comment])) -> (content: Content, comments: [Comment]) {
        (content: values.0, comments: values.1)
    }
}
