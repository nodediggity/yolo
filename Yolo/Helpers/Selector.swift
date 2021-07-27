//
//  Selector.swift
//  Yolo
//
//  Created by Gordon Smith on 27/07/2021.
//

import Foundation

func createSelector<TInput: Hashable, TOutput, T1>(selector1: @escaping (TInput) -> T1, _ combine: @escaping (T1) -> TOutput) -> (TInput) -> TOutput {
    memoize { value in
        combine(selector1(value))
    }
}
