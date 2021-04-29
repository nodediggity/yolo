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

    private let cell = FeedCardView()
    private let model: FeedCardViewModel
    
    public init(model: FeedCardViewModel) {
        self.model = model
    }
    
    public func displayImage(for view: Image) {
        switch view {
        case let .user(image):
            cell.userImageView.image = image
        case let .body(image):
            cell.cardImageView.image = image
        }
    }
    
    public func view() -> FeedCardView {
        
        cell.nameLabel.text = model.name
        cell.aboutLabel.text = model.about
        cell.likesCountLabel.text = model.likes
        cell.commentsCountLabel.text = model.comments
        cell.sharesCountLabel.text = model.shares
        
        load()
        return cell
    }
    
    public func cancel() {
        onLoadImageCancel?()
    }
}

private extension FeedCardCellController {
    func load() {
        onLoadImage?()
    }
}
