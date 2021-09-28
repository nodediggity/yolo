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
    public typealias InteractionService = (_ id: String, _ interaction: Interaction) -> AnyPublisher<Interactions, Error>
    public typealias SelectionHandler = (FeedItem) -> Void
    
    public static func compose(loader: @escaping FeedLoader, imageLoader: @escaping ImageLoader, interactionService: @escaping InteractionService, selection: @escaping SelectionHandler) -> ListViewController {
        
        let viewController = ListViewController()
        viewController.title = FeedPresenter.title
        
        let adapter = ResourcePresentationAdapter<[FeedItem], FeedViewAdapter>(service: loader)
        adapter.presenter = ResourcePresenter(
            view: FeedViewAdapter(
                controller: viewController,
                imageLoader: imageLoader,
                interactionService: interactionService,
                selection: selection
            ),
            loadingView: WeakRefVirtualProxy(viewController),
            mapper: FeedViewModel.init
        )
        
        viewController.onLoad = adapter.execute
        
        viewController.configure = { tableView in
            tableView.register(FeedCardView.self)
        }
        
        return viewController
    }
}

private final class FeedViewAdapter {
    
    private weak var controller: ListViewController?
    private let imageLoader: FeedUIComposer.ImageLoader
    private let interactionService: FeedUIComposer.InteractionService
    private let selection: FeedUIComposer.SelectionHandler
    
    init(controller: ListViewController, imageLoader: @escaping FeedUIComposer.ImageLoader, interactionService: @escaping FeedUIComposer.InteractionService, selection: @escaping FeedUIComposer.SelectionHandler) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.interactionService = interactionService
        self.selection = selection
    }
}

extension FeedViewAdapter: ResourceView {
    typealias ResourceViewModel = FeedViewModel
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { item in
                        
            let view = FeedCardCellController()
            
            view.display(FeedCardPresenter.map(item))
            
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
            
            // MARK:- Interactions
            let interactionsAdapter = ResourcePresentationAdapter<Interactions, ResourceViewAdapter<Interactions>>(service: { [interactionService] in
                interactionService(item.id, item.interactions.isLiked ? .unlike : .like)
            })
            
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

            view.onToggleLikeAction = interactionsAdapter.execute
            
            return CellController(id: item, view)
        })
    }
}

extension FeedItem {
    func clone(with interactions: Interactions) -> Self {
        FeedItem(id: id, imageURL: imageURL, user: user, interactions: interactions)
    }

    func toggleLikedState() -> Self {
        return interactions.isLiked ? cloneAsUnliked() : cloneAsLiked()
    }

    func cloneAsLiked() -> Self {
        clone(with: interactions.asLiked())
    }

    func cloneAsUnliked() -> Self {
        clone(with: interactions.asUnliked())
    }
}
