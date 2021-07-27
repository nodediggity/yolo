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
    
    private lazy var store: Store = {
        Store(state: nil, mapper: rootMapper)
    }()
    
    convenience init(httpClient: HTTPClient, store: Store) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let scene = (scene as? UIWindowScene) {
            configure(window: .init(windowScene: scene))
            configureNavigationAttributes()
        }
    }
    
    func configure(window: UIWindow) {
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
    }
}

private extension SceneDelegate {
    
    func configureNavigationAttributes() {
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.label
        ]

        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.label
        ]

        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = UIColor.label
    }
    
    func makeFeedScene() -> UIViewController {
        FeedUIComposer.compose(
           loader: makeRemoteFeedLoader,
            imageLoader: makeRemoteImageLoader,
            interactionService: makeRemoteInteractionService,
            selection: { [self] in showContentScene(id: $0.id) }
       )
    }
    
    func showContentScene(id: String) {
        let loader = makeRemoteContentWithCommentsLoader(id: id)
        let viewController = ContentUIComposer.compose(
            loader: { loader },
            imageLoader: makeRemoteImageLoader,
            interactionService: makeRemoteInteractionService
        )
        navController.pushViewController(viewController, animated: true)
    }
    
    func makeRemoteFeedLoader() -> AnyPublisher<[FeedItem], Error> {
        let request = URLRequest(url: baseURL.appendingPathComponent("feed"))
        return httpClient
            .dispatchPublisher(for: request)
            .tryMap(FeedResponseMapper.map)
            .map(\.items)
            .handleEvents(receiveOutput: { [store] items in
                store.dispatch(FeedLoadedEvent(payload: items))
            })
            .select(from: store, using: feedSelector)
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
    
    func makeRemoteInteractionService(id: String, interaction: Interaction) -> AnyPublisher<Interactions, Error> {
        var request = URLRequest(
            url: baseURL
                .appendingPathComponent("interactions")
                .appendingPathComponent(id)
        )
        request.httpMethod = interaction == .like ? "PUT" : "DELETE"
        
        return httpClient
            .dispatchPublisher(for: request)
            .tryMap(InteractionResposneMapper.map)
            .eraseToAnyPublisher()
    }
}
