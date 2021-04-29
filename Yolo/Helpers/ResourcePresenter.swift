//
//  ResourcePresenter.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}

public protocol ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}

public struct ResourceLoadingViewModel {
    public let isLoading: Bool
    public init(isLoading: Bool) {
        self.isLoading = isLoading
    }
}

public protocol ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel)
}

public struct ResourceErrorViewModel: Equatable {
    public let message: String?

    public static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: nil)
    }

    public static func error(message: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: message)
    }
}

public final class ResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel

    private let view: View
    private let loadingView: ResourceLoadingView?
    private let errorView: ResourceErrorView?

    private let mapper: Mapper

    public init(view: View, loadingView: ResourceLoadingView? = nil, errorView: ResourceErrorView? = nil, mapper: @escaping Mapper) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }

    public init(view: View, loadingView: ResourceLoadingView? = nil, errorView: ResourceErrorView? = nil) where Resource == View.ResourceViewModel {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
        mapper = { $0 }
    }

    public func didStartLoading() {
        loadingView?.display(ResourceLoadingViewModel(isLoading: true))
        errorView?.display(.noError)
    }

    public func didFinishLoading(with resource: Resource) {
        do {
            view.display(try mapper(resource))
            loadingView?.display(ResourceLoadingViewModel(isLoading: false))
        } catch {
            didFinishLoading(with: error)
        }
    }

    public func didFinishLoading(with error: Error) {
        loadingView?.display(ResourceLoadingViewModel(isLoading: false))
        errorView?.display(.error(message: error.localizedDescription))
    }
}
