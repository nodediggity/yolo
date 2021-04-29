//
//  FeedPresentationAdapter.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import Foundation
import Combine

class FeedPresentationAdapter {
    
    var presenter: ResourcePresenter<[FeedItem], FeedViewAdapter>?
    
    private let loader: () -> AnyPublisher<[FeedItem], Error>
    private var cancellable: Cancellable?
    
    private var isPending = false
    
    init(loader: @escaping () -> AnyPublisher<[FeedItem], Error>) {
        self.loader = loader
    }
    
    func execute() {
        guard !isPending else { return }
        isPending = true
        presenter?.didStartLoading()
        cancellable = loader()
            .dispatchOnMainQueue()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isPending = false
            })
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoading(with: feed)
                    self?.isPending = false
                }
            )
    }
}
