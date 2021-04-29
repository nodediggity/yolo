//
//  FeedCardCellController.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit

public final class FeedCardCellController {
    
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
    
    public func view(in tableView: UITableView) -> FeedCardView {
        cell = tableView.dequeueReusableCell()
        load()
        return configure(cell)!
    }
    
    public func select() {
        onSelection?()
    }
    
    public func preload() {
        load()
    }
    
    public func cancel() {
        onLoadImageCancel?()
    }
}

private extension FeedCardCellController {
    func load() {
        onLoadImage?()
    }
    
    func configure(_ cell: FeedCardView?) -> FeedCardView? {
        cell?.selectionStyle = .none
        
        cell?.nameLabel.text = model.name
        cell?.aboutLabel.text = model.about
        cell?.likesCountLabel.text = model.likes
        cell?.commentsCountLabel.text = model.comments
        cell?.sharesCountLabel.text = model.shares
        
        return cell
    }

}
