//
//  ResourcePresentationAdapter.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import Foundation
import Combine

class ResourcePresentationAdapter<Resource, View: ResourceView>: Cancellable {
    var presenter: ResourcePresenter<Resource, View>?

    private let service: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?

    private var isPending = false

    init(service: @escaping () -> AnyPublisher<Resource, Error>) {
        self.service = service
    }

    func execute() {
        guard !isPending else { return }
        isPending = true
        presenter?.didStartLoading()
        cancellable = service()
            .dispatchOnMainQueue()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isPending = false
            })
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.presenter?.didFinishLoading(with: error)
                    }
                    self?.isPending = false
                }, receiveValue: { [weak self] resource in
                    self?.presenter?.didFinishLoading(with: resource)
                    self?.isPending = false
                }
            )
    }

    func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }
}
