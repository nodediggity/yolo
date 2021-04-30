//
//  ContentViewController.swift
//  Yolo
//
//  Created by Gordon Smith on 30/04/2021.
//

import UIKit

public final class ContentViewController: NSObject {

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
        configureUI()
        return cell!
    }
}

private extension ContentViewController {
    func configureUI() {
        cell?.selectionStyle = .none
    }
}
