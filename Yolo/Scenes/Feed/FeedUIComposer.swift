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
        
        let adapter = ResourcePresentationAdapter<[FeedItem], FeedViewAdapter>(service: loader)
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

private final class FeedViewAdapter {
    
    private weak var controller: FeedViewController?
    private let imageLoader: FeedUIComposer.ImageLoader
    private let selection: FeedUIComposer.SelectionHandler
    
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
            
            // MARK:- UserImageView
            let userImageViewAdapter = ResourcePresentationAdapter<Data, ResourceViewAdapter<UIImage>>(service: { [imageLoader] in
                imageLoader(item.user.imageURL)
            })
            
            userImageViewAdapter.presenter = ResourcePresenter(
                view: ResourceViewAdapter { [weak view] in view?.displayImage(for: .user($0)) },
                mapper: UIImage.tryMake(data:)
            )
                        
            // MARK:- BodyImageView
            let bodyImageViewAdapter = ResourcePresentationAdapter<Data, ResourceViewAdapter<UIImage>>(service: { [imageLoader] in
                imageLoader(item.imageURL)
            })
            
            bodyImageViewAdapter.presenter = ResourcePresenter(
                view: ResourceViewAdapter { [weak view] in view?.displayImage(for: .body($0)) },
                mapper: UIImage.tryMake(data:)
            )
            
            view.onLoadImage = {
                userImageViewAdapter.execute()
                bodyImageViewAdapter.execute()
            }
            
            view.onLoadImageCancel = {
                userImageViewAdapter.cancel()
                bodyImageViewAdapter.cancel()
            }
            
            view.onSelection = { [selection] in
                selection(item)
            }
            
            return view
        })
    }
}

public final class ResourceViewAdapter<ResourceViewModel>: ResourceView {
    private var handler: () -> (ResourceViewModel) -> Void

    public init(handler: @escaping (ResourceViewModel) -> Void) {
        self.handler = { handler }
    }

    public func display(_ viewModel: ResourceViewModel) {
        handler()(viewModel)
    }
}

public extension UIImage {
    struct InvalidImageData: Error {}
    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}
