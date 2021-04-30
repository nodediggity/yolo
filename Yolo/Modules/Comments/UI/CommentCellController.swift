//
//  CommentCellController.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import UIKit

public final class CommentCellController: NSObject {
    
    public var onLoadImage: (() -> Void)?
    public var onLoadImageCancel: (() -> Void)?
    
    private var cell: CommentView?
    private let model: CommentViewModel
    
    public init(model: CommentViewModel) {
        self.model = model
    }
}

extension CommentCellController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.selectionStyle = .none
        
        cell?.nameLabel.text = model.name
        cell?.bodyTextLabel.text = model.text
        load()
        return cell!
    }
}

extension CommentCellController: ResourceView {
    public typealias ResourceViewModel = UIImage
    public func display(_ viewModel: ResourceViewModel) {
        cell?.userImageView.image = viewModel
    }
}

private extension CommentCellController {
    func load() {
        onLoadImage?()
    }
    
    func cancel() {
        releaseCellForReuse()
        onLoadImageCancel?()
    }

    func releaseCellForReuse() {
        cell = nil
    }
}
