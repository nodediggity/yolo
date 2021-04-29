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
            
            view.onLoadImage = { [loadImage, weak view] in
                
                loadImage(item.user.imageURL) {
                    view?.displayImage(for: .user($0))
                }
                
                loadImage(item.imageURL) {
                    view?.displayImage(for: .body($0))
                }
            }
            
            view.onLoadImageCancel = { [weak self] in
                [item.user.imageURL, item.imageURL].forEach { url in
                    self?.cancellables[url]?.cancel()
                    self?.cancellables[url] = nil
                }
            }
            
            return view
        })
    }
    
    func loadImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        guard cancellables[url] == nil else { return }
        cancellables[url] = imageLoader(url)
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { _ in
                },
                receiveValue: { imageData in
                    completion(UIImage.init(data: imageData))
                }
            )
    }
}
