//
//  FeedPresenter.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import Foundation

public struct FeedLoadingViewModel {
    public let isLoading: Bool
}

public protocol FeedLoadingView: class {
    func display(_ viewModel: FeedLoadingViewModel)
}

public struct FeedViewModel {
    public let feed: [FeedItem]
}

public protocol FeedView: class {
    func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter {
    public static var title: String {
        "Discover"
    }
    
    private var view: FeedView?
    private weak var loadingView: FeedLoadingView?
    
    init(view: FeedView?, loadingView: FeedLoadingView? = nil) {
        self.view = view
        self.loadingView = loadingView
    }
    
    public func didStartLoadingFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedItem]) {
        view?.display(FeedViewModel(feed: feed))
        loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
}
