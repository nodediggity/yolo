//
//  ContentUIComposer.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import Foundation
import Combine

public enum ContentUIComposer {
    
    public typealias Loader = () -> AnyPublisher<(content: Content, comments: [Comment]), Error>
    
    public static func compose(loader: @escaping Loader) -> ListViewController {
        
        let adapter = ResourcePresentationAdapter<(content: Content, comments: [Comment]), ContentViewAdapter>(service: loader)
        
        let viewController = ListViewController()
        
        adapter.presenter = ResourcePresenter(
            view: ContentViewAdapter(controller: viewController),
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
    
    init(controller: ListViewController) {
        self.controller = controller
    }
}

extension ContentViewAdapter: ResourceView {
    typealias ResourceViewModel = (content: Content, comments: [Comment])
    
    func display(_ viewModel: ResourceViewModel) {
        let (content, comments) = viewModel
        
        let contentSection: [CellController] = [ContentViewController()].map { view in
            view.display(content)
            return .init(id: content, view)
        }
        
        let commentSection: [CellController] = comments.map { item in
            let view = CommentCellController(model: CommentPresenter.map(item))
            return .init(id: item, view)
        }
        
        controller?.display(contentSection, commentSection)
    }
}
