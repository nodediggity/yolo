//
//  EmptySectionViewController.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import UIKit

public final class EmptySectionViewController: NSObject {
    
    
    private var cell = EmptySectionView()
    
    init(text: String) {
        cell.messageLabel.text = text
    }
}

extension EmptySectionViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell
    }
}
