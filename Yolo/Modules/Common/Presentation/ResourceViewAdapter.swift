//
//  ResourceViewAdapter.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import Foundation

public final class ResourceViewAdapter<ResourceViewModel>: ResourceView {
    private var handler: () -> (ResourceViewModel) -> Void

    public init(handler: @escaping (ResourceViewModel) -> Void) {
        self.handler = { handler }
    }

    public func display(_ viewModel: ResourceViewModel) {
        handler()(viewModel)
    }
}
