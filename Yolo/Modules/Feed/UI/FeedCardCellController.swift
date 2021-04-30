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
    
    public var onToggleLikeAction: (() -> Void)?
    
    public var onSelection: (() -> Void)?

    private var cell: FeedCardView?
    private var model: FeedCardViewModel?
    
    public override init() {
        super.init()
    }
    
    public func displayImage(for view: Image) {
        switch view {
        case let .user(image):
            cell?.userImageView.image = image
        case let .body(image):
            cell?.cardImageView.image = image
        }
    }
    
    public func display(_ model: FeedCardViewModel) {
        self.model = model
        configureCell()
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
        
        cell?.onToggleLikeAction = { [weak self] in
            self?.onToggleLikeAction?()
        }
        
        configureCell()
                
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
    
    func configureCell() {
        guard let model = model else { return }
        cell?.nameLabel.text = model.name
        cell?.aboutLabel.text = model.about
        cell?.likesCountLabel.text = model.likes
        cell?.commentsCountLabel.text = model.comments
        cell?.sharesCountLabel.text = model.shares
        
        cell?.likeButton.tintColor = model.isLiked ? .red : #colorLiteral(red: 0.4941176471, green: 0.5568627451, blue: 0.6431372549, alpha: 1)
    }
}
