//
//  FeedUIComposer.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit
import Combine

public enum FeedUIComposer {
    
    public typealias FeedLoader = () -> AnyPublisher<[FeedItem], Error>
    public typealias ImageLoader = (_ imageURL: URL) -> AnyPublisher<Data, Error>
    
    public static func compose(loader: @escaping FeedLoader, imageLoader: @escaping ImageLoader) -> FeedViewController {
        
        let viewController = FeedViewController()
        viewController.title = FeedPresenter.title
        
        let adapter = FeedPresentationAdapter(loader: loader)
        adapter.presenter = FeedPresenter(
            view: FeedViewAdapter(controller: viewController, imageLoader: imageLoader),
            loadingView: viewController
        )
        
        viewController.onLoad = adapter.execute
        
        return viewController
    }
}

private final class FeedViewAdapter {
    
    private weak var controller: FeedViewController?
    private let imageLoader: FeedUIComposer.ImageLoader
    
    private var cancellables: [URL: AnyCancellable] = [:]
    
    init(controller: FeedViewController, imageLoader: @escaping FeedUIComposer.ImageLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
}

extension FeedViewAdapter: FeedView {
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { item in
            let model = FeedCardPresenter.map(item)
            let view = FeedCardCellController(model: model)
            
            view.onLoadImage = { [loadImage] in
                
                loadImage(item.user.imageURL) { _ in
                    
                }
                
                loadImage(item.imageURL) { _ in
                    
                }
            }
            
            return view
        })
    }
    
    func loadImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        cancellables[url] = imageLoader(url)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
    }
}
