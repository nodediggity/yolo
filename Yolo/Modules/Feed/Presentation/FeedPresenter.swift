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
    
    public weak var view: FeedView?
    public weak var loadingView: FeedLoadingView?
    
    public func didStartLoadingFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedItem]) {
        view?.display(FeedViewModel(feed: feed))
        loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
}
