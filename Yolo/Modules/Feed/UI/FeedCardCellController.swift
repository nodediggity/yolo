//
//  FeedCardCellController.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit

public final class FeedCardCellController {
    
    public var onLoadImage: (() -> Void)?
    
    private let cell = FeedCardView()
    private let model: FeedCardViewModel
    
    public init(model: FeedCardViewModel) {
        self.model = model
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
}

private extension FeedCardCellController {
    func load() {
        onLoadImage?()
    }
}
