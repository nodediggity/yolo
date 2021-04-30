//
//  ContentViewController.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import UIKit

public final class ContentViewController: NSObject {

    public var onLoadImage: (() -> Void)?
    public var onToggleLikeAction: (() -> Void)?
    
    private var cell: ContentView?
    private var model: Content?
    
    public override init() {
        super.init()
    }
    
    func display(_ model: Content) {
        self.model = model
        configureUI()
    }
    
}

extension ContentViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.selectionStyle = .none
        
        cell?.onToggleLikeAction = { [weak self] in
            self?.onToggleLikeAction?()
        }
        
        configureUI()
        load()
        return cell!
    }
}

extension ContentViewController: ResourceView {
    public typealias ResourceViewModel = UIImage
    public func display(_ viewModel: ResourceViewModel) {
        cell?.contentImageView.image = viewModel
    }
}

private extension ContentViewController {
    func configureUI() {
        guard let model = model else { return }

        cell?.likesCountLabel.text = "\(model.interactions.likes)"
        cell?.commentsCountLabel.text = "\(model.interactions.comments)"
        cell?.sharesCountLabel.text = "\(model.interactions.shares)"
        
        cell?.likeButton.tintColor = model.interactions.isLiked ? .red : #colorLiteral(red: 0.4941176471, green: 0.5568627451, blue: 0.6431372549, alpha: 1)
        
    }
    
    func load() {
        onLoadImage?()
    }
}
