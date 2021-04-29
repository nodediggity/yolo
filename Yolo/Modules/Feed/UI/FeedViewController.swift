//
//  FeedViewController.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit

public final class FeedViewController: UITableViewController {
    
    public var onLoad: (() -> Void)?
    
    private var controllers: [FeedCardCellController] = [] {
        didSet { tableView.reloadData() }
    }
    
    public func display(_ controllers: [FeedCardCellController]) {
        self.controllers = controllers
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl(frame: .zero)
        load()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        controllers.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        controller(for: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(for: indexPath)
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
        
    func controller(for indexPath: IndexPath) -> FeedCardCellController {
        controllers[indexPath.row]
    }
    
    func cancelCellControllerLoad(for indexPath: IndexPath) {
        controller(for: indexPath).cancel()
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
