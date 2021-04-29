//
//  FeedViewController+TestHelpers.swift
//  YoloTests
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit
import Yolo

extension FeedViewController {
    
    private var FEED_SECTION: Int { 0 }
    
    var isShowingLoadingIndicator: Bool {
        guard let refreshControl = refreshControl else { return false }
        return refreshControl.isRefreshing
    }
    
    var numberOfRenderedFeedItems: Int {
        guard tableView.numberOfSections > FEED_SECTION else { return 0 }
        return tableView.numberOfRows(inSection: FEED_SECTION)
    }
    
    func feedCardView(at row: Int) -> UITableViewCell? {
        let indexPath = IndexPath(row: row, section: FEED_SECTION)
        return tableView(tableView, cellForRowAt: indexPath)
    }
    
    @discardableResult
    func simulateFeedCardVisible(at row: Int) -> FeedCardView? {
        return feedCardView(at: row) as? FeedCardView
    }
    
    @discardableResult
    func simulateFeedCardNotVisible(at row: Int) -> FeedCardView? {
        let view = simulateFeedCardVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: FEED_SECTION)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    func simulateFeedCardNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: FEED_SECTION)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedCardNoLongerNearVisible(at row: Int) {
        simulateFeedCardNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: FEED_SECTION)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func renderedFeedCardUserImageData(at row: Int) -> Data? {
        return simulateFeedCardVisible(at: row)?.renderedImageForUser
    }
    
    func renderedFeedCardBodyImageData(at row: Int) -> Data? {
        return simulateFeedCardVisible(at: row)?.renderedImageForCard
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.beginRefreshing()
        scrollViewDidEndDragging(tableView, willDecelerate: false)
    }
}