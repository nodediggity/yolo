//
//  FeedCardCellController.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit

public final class FeedCardCellController {
    
    private let cell = FeedCardView()
    private let model: FeedItem
    
    init(model: FeedItem) {
        self.model = model
    }
    
    public func view() -> FeedCardView {
        
        cell.nameLabel.text = model.user.name
        cell.aboutLabel.text = model.user.about
        cell.likesCountLabel.text = "\(model.interactions.likes)"
        cell.commentsCountLabel.text = "\(model.interactions.comments)"
        cell.sharesCountLabel.text = "\(model.interactions.shares)"
        
        return cell
    }
}
