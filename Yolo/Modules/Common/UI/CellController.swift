//
//  CellController.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit

public struct CellController {
    let id: AnyHashable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?

    public init(id: AnyHashable = UUID(), _ dataSource: UITableViewDataSource) {
        self.id = id
        self.dataSource = dataSource
        delegate = dataSource as? UITableViewDelegate
        dataSourcePrefetching = dataSource as? UITableViewDataSourcePrefetching
    }
}

extension CellController: Equatable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}

extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
