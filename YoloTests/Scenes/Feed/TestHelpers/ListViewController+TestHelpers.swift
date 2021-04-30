//
//  ListViewController+TestHelpers.swift
//  YoloTests
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit
import Yolo

extension ListViewController {
    
    override public func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    var isShowingLoadingIndicator: Bool {
        guard let refreshControl = refreshControl else { return false }
        return refreshControl.isRefreshing
    }
    
    var numberOfSections: Int {
        numberOfSections(in: tableView)
    }
    
    func numberOfRenderedItems(in section: Int) -> Int {
        guard tableView.numberOfSections > section else { return 0 }
        return tableView.numberOfRows(inSection: section)
    }
    
    func cell(row: Int, section: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
            
    func simulateListItemNotVisible(row: Int, section: Int) -> UITableViewCell? {
        let view = cell(row: row, section: section)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: section)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    func simulateListItemNearVisible(row: Int, section: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: section)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateListItemNoLongerNearVisible(row: Int, section: Int) {
        simulateListItemNearVisible(row: row, section: section)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: section)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
        
    func simulateUserInitiatedReload() {
        refreshControl?.beginRefreshing()
        scrollViewDidEndDragging(tableView, willDecelerate: false)
    }
    
    func simulateListItemSelection(row: Int, section: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: section)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
}

// FEED
extension ListViewController {

    private var FEED_SECTION: Int { 0 }

    var numberOfRenderedFeedItems: Int {
        numberOfRenderedItems(in: FEED_SECTION)
    }
    
    func feedCardView(at row: Int) -> UITableViewCell? {
        cell(row: row, section: FEED_SECTION) as? FeedCardView
    }
    
    @discardableResult
    func simulateFeedCardVisible(at row: Int) -> FeedCardView? {
        return feedCardView(at: row) as? FeedCardView
    }
    
    @discardableResult
    func simulateFeedCardNotVisible(at row: Int) -> FeedCardView? {
        return simulateListItemNotVisible(row: row, section: FEED_SECTION) as? FeedCardView
    }
    
    func simulateFeedCardNearVisible(at row: Int) {
        simulateListItemNearVisible(row: row, section: FEED_SECTION)
    }
    
    func simulateFeedCardNoLongerNearVisible(at row: Int) {
        simulateListItemNoLongerNearVisible(row: row, section: FEED_SECTION)
    }
    
    func simulateFeedCardSelection(at row: Int) {
        simulateListItemSelection(row: row, section: FEED_SECTION)
    }
}

// Content
extension ListViewController {

    private var CONTENT_SECTION: Int { 0 }
    private var COMMENT_SECTION: Int { 1 }

    func contentView() -> UITableViewCell? {
        cell(row: 0, section: CONTENT_SECTION) as? ContentView
    }
    
    var numberOfRenderedComments: Int {
        numberOfRenderedItems(in: COMMENT_SECTION)
    }
    
    func commentView(at row: Int) -> UITableViewCell? {
        cell(row: row, section: COMMENT_SECTION) as? CommentView
    }
}
