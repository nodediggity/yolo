//
//  ContentUIComposer.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import UIKit
import Combine

public enum ContentUIComposer {
    
    public typealias Loader = () -> AnyPublisher<(content: Content, comments: [Comment]), Error>
    public typealias InteractionService = (_ id: String, _ interaction: Interaction) -> AnyPublisher<Interactions, Error>
    public typealias ImageLoader = (_ imageURL: URL) -> AnyPublisher<Data, Error>

    public static func compose(loader: @escaping Loader, imageLoader: @escaping ImageLoader, interactionService: @escaping InteractionService) -> ListViewController {
        
        let adapter = ResourcePresentationAdapter<(content: Content, comments: [Comment]), ContentViewAdapter>(service: loader)
        
        let viewController = ListViewController()
        
        adapter.presenter = ResourcePresenter(
            view: ContentViewAdapter(
                controller: viewController,
                imageLoader: imageLoader,
                interactionService: interactionService
            ),
            loadingView: WeakRefVirtualProxy(viewController)
        )
        
        viewController.onLoad = adapter.execute
        
        viewController.configure = { tableView in
            tableView.register(ContentView.self)
            tableView.register(CommentView.self)
        }
        
        return viewController
    }
}

private final class ContentViewAdapter {
    private weak var controller: ListViewController?
    private let imageLoader: ContentUIComposer.ImageLoader
    private let interactionService: ContentUIComposer.InteractionService

    init(controller: ListViewController, imageLoader: @escaping ContentUIComposer.ImageLoader, interactionService: @escaping ContentUIComposer.InteractionService) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.interactionService = interactionService
    }
}

extension ContentViewAdapter: ResourceView {
    typealias ResourceViewModel = (content: Content, comments: [Comment])
    
    func display(_ viewModel: ResourceViewModel) {
        let (content, comments) = viewModel
        
        let contentSection: [CellController] = [ContentViewController()].map { view in
            var model = content
            view.display(model)
            
            // MARK:- ImageView
            let adapter = ResourcePresentationAdapter<Data, WeakRefVirtualProxy<ContentViewController>>(service: { [imageLoader] in
                imageLoader(content.imageURL)
            })
            
            adapter.presenter = ResourcePresenter(
                view: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake(data:)
            )
            
            // MARK:- Interactions
            let interactionsAdapter = ResourcePresentationAdapter<Interactions, ResourceViewAdapter<Interactions>>(service: { [interactionService] in
                interactionService(model.id, model.interactions.isLiked ? .unlike : .like)
            })

            interactionsAdapter.presenter = ResourcePresenter(
                view: ResourceViewAdapter { model = model.clone(with: $0) },
                errorView: ResourceErrorViewAdapter { [weak view] _ in
                    model = content
                    view?.display(model)
                }
            )
        
            view.onToggleLikeAction = { [weak view] in
                // dispatch request
                interactionsAdapter.execute()
                // perform optimistic UI update
                model = model.toggleLikedState()
                view?.display(model)
            }
        
            view.onLoadImage = {
                adapter.execute()
            }
            
            return .init(id: content, view)
        }
        
        if comments.isEmpty {
            let placeholderSection = EmptySectionViewController(text: ContentPresenter.placeholderComments)
            controller?.display(contentSection, [.init(placeholderSection)])
            return
        }
        
        let commentSection: [CellController] = comments.map { item in
            let view = CommentCellController(model: CommentPresenter.map(item))
            
            let adapter = ResourcePresentationAdapter<Data, WeakRefVirtualProxy<CommentCellController>>(service: { [imageLoader] in imageLoader(item.user.imageURL)
            })
            
            adapter.presenter = ResourcePresenter(view: WeakRefVirtualProxy(view), mapper: UIImage.tryMake(data:))

            view.onLoadImage = adapter.execute

    
            return .init(id: item, view)
        }
        
        controller?.display(contentSection, commentSection)
    }
}

private extension Content {
    func clone(with interactions: Interactions) -> Self {
        Content(id: id, imageURL: imageURL, user: user, interactions: interactions)
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
