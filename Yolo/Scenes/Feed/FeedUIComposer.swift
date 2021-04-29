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
    public typealias SelectionHandler = (FeedItem) -> Void
    
    public static func compose(loader: @escaping FeedLoader, imageLoader: @escaping ImageLoader, selection: @escaping SelectionHandler) -> FeedViewController {
        
        let viewController = FeedViewController()
        viewController.title = FeedPresenter.title
        
        let adapter = FeedPresentationAdapter(loader: loader)
        adapter.presenter = ResourcePresenter(
            view: FeedViewAdapter(
                controller: viewController,
                imageLoader: imageLoader,
                selection: selection
            ),
            loadingView: WeakRefVirtualProxy(viewController),
            mapper: FeedViewModel.init
        )
        
        viewController.onLoad = adapter.execute
        
        return viewController
    }
}

final class FeedViewAdapter {
    
    private weak var controller: FeedViewController?
    private let imageLoader: FeedUIComposer.ImageLoader
    private let selection: FeedUIComposer.SelectionHandler
    
    private var cancellables: [URL: AnyCancellable] = [:]
    
    init(controller: FeedViewController, imageLoader: @escaping FeedUIComposer.ImageLoader, selection: @escaping FeedUIComposer.SelectionHandler) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
}

extension FeedViewAdapter: ResourceView {
    typealias ResourceViewModel = FeedViewModel
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { item in
            let model = FeedCardPresenter.map(item)
            let view = FeedCardCellController(model: model)
            
            view.onSelection = { [selection] in
                selection(item)
            }
            
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

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: ResourceView where T: ResourceView {
    func display(_ viewModel: T.ResourceViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {
        object?.display(viewModel)
    }
}
