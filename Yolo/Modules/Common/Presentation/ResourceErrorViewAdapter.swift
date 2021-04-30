//
//  ResourceErrorViewAdapter.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import Foundation

public final class ResourceErrorViewAdapter: ResourceErrorView {
    private var handler: () -> (ResourceErrorViewModel) -> Void

    public init(handler: @escaping (ResourceErrorViewModel) -> Void) {
        self.handler = { handler }
    }

    public func display(_ viewModel: ResourceErrorViewModel) {
        handler()(viewModel)
    }
}
