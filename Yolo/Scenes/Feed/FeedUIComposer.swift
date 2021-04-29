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
    
    public static func compose(loader: @escaping FeedLoader) -> FeedViewController {
        
        let viewController = FeedViewController()
        viewController.title = FeedPresenter.title
        
        let adapter = FeedPresentationAdapter(loader: loader)
        adapter.presenter = FeedPresenter(
            view: FeedViewAdapter(controller: viewController),
            loadingView: viewController
        )
        
        viewController.onLoad = adapter.execute
        
        return viewController
    }
}

private final class FeedViewAdapter {
    private weak var controller: FeedViewController?
    
    init(controller: FeedViewController) {
        self.controller = controller
    }
}

extension FeedViewAdapter: FeedView {
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map(FeedCardCellController.init))
    }
}
