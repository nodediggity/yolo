//
//  FeedViewController.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit

public final class FeedViewController: UITableViewController {
    
    public var onLoad: (() -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl(frame: .zero)
        load()
    }
    
    public override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard refreshControl?.isRefreshing == true else { return }
        load()
    }
}

private extension FeedViewController {
    func load() {
        onLoad?()
    }
}

extension FeedViewController: FeedLoadingView {
    public func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}
