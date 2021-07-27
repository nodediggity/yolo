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

func createSelector<TInput: Hashable, TOutput, T1, T2>(selector1: @escaping (TInput) -> T1, _ selector2: @escaping (TInput) -> T2, _ combine: @escaping (T1, T2) -> TOutput) -> (TInput) -> TOutput {
    memoize { state in
        combine(selector1(state), selector2(state))
    }
}

func createSelector<TInput: Hashable, TOutput, T1, T2, T3>(selector1: @escaping (TInput) -> T1, _ selector2: @escaping (TInput) -> T2, selector3: @escaping (TInput) -> T3, _ combine: @escaping (T1, T2, T3) -> TOutput) -> (TInput) -> TOutput {
    memoize { state in
        combine(selector1(state), selector2(state), selector3(state))
    }
}
