//
//  UITableView+Dequeueing.swift
//  Yolo
//
//  Created by Gordon Smith on 29/04/2021.
//

import UIKit

public extension UITableView {
    func register<T: UITableViewCell>(_ name: T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: name))
    }

    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
