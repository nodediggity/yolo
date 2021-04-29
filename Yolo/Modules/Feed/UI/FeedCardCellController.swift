//
//  FeedCardCellController.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit

public final class FeedCardCellController: NSObject {
    
    public enum Image {
        case user(UIImage?)
        case body(UIImage?)
    }
    
    public var onLoadImage: (() -> Void)?
    public var onLoadImageCancel: (() -> Void)?
    
    public var onSelection: (() -> Void)?

    private var cell: FeedCardView?
    private let model: FeedCardViewModel
    
    public init(model: FeedCardViewModel) {
        self.model = model
    }
    
    public func displayImage(for view: Image) {
        switch view {
        case let .user(image):
            cell?.userImageView.image = image
        case let .body(image):
            cell?.cardImageView.image = image
        }
    }
}

extension FeedCardCellController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.userImageView.image = nil
        cell?.cardImageView.image = nil
        
        cell?.selectionStyle = .none
        
        cell?.nameLabel.text = model.name
        cell?.aboutLabel.text = model.about
        cell?.likesCountLabel.text = model.likes
        cell?.commentsCountLabel.text = model.comments
        cell?.sharesCountLabel.text = model.shares
        
        load()
        return cell!
    }
}

extension FeedCardCellController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelection?()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancel()
    }
}

extension FeedCardCellController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        load()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancel()
    }
}

private extension FeedCardCellController {
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
