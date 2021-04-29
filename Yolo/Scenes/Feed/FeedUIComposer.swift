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
        
        let presenter = FeedPresenter()
        presenter.view = viewController
        presenter.loadingView = viewController
        
        adapter.presenter = presenter
        
        viewController.onLoad = adapter.execute
        
        return viewController
    }
}
