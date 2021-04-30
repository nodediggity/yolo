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
    public typealias ImageLoader = (_ imageURL: URL) -> AnyPublisher<Data, Error>

    public static func compose(loader: @escaping Loader, imageLoader: @escaping ImageLoader) -> ListViewController {
        
        let adapter = ResourcePresentationAdapter<(content: Content, comments: [Comment]), ContentViewAdapter>(service: loader)
        
        let viewController = ListViewController()
        
        adapter.presenter = ResourcePresenter(
            view: ContentViewAdapter(controller: viewController, imageLoader: imageLoader),
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
    init(controller: ListViewController, imageLoader: @escaping ContentUIComposer.ImageLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
}

extension ContentViewAdapter: ResourceView {
    typealias ResourceViewModel = (content: Content, comments: [Comment])
    
    func display(_ viewModel: ResourceViewModel) {
        let (content, comments) = viewModel
        
        let contentSection: [CellController] = [ContentViewController()].map { view in
            
            view.display(content)
            
            let adapter = ResourcePresentationAdapter<Data, WeakRefVirtualProxy<ContentViewController>>(service: { [imageLoader] in
                imageLoader(content.imageURL)
            })
            
            adapter.presenter = ResourcePresenter(view: WeakRefVirtualProxy(view), mapper: UIImage.tryMake(data:))
            
            view.onLoadImage = adapter.execute
            
            return .init(id: content, view)
        }
        
        let commentSection: [CellController] = comments.map { item in
            let view = CommentCellController(model: CommentPresenter.map(item))
            return .init(id: item, view)
        }
        
        controller?.display(contentSection, commentSection)
    }
}
